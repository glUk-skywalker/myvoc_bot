# frozen_string_literal: true

def log(msg)
  puts "#{Time.now}\t#{msg}"
end

require_relative 'requires'

REMIND_GAP = 60 * ENV['REMIND_FREQUENCY'].to_i

log 'starting the reminder daemon..'

Linguo.api_key = 'demo'
token = ENV['BOT_TOKEN']

log 'waiting in order to ensure Chrome is started..'
sleep 15 # wait while chrome is starting

words = Words.new

begin
  browser = Browser.new
rescue => e
  log 'whoops! failed to initialize browser :('
  log e.message
  log 'retrying..'
  retry
end

loop do
  hour = Time.now.hour

  if hour >= 12 && hour <= 19
    log 'reminding!'
    words.uniq!

    word = words.pick!.get(:word)
    begin
      msg = ''
      msg = browser.get_stringified_info_for(word)
    rescue => e
      log 'whoops! failed to get info :('
      log e.message
      browser = Browser.new
      retry
    end
    msg += "\n---\nwords active: #{words.active.count} (of #{words.count})"

    Telegram::Bot::Client.run(token) do |bot|
      bot.api.send_message(chat_id: ENV['TARGET'], text: msg, parse_mode: 'html')
    end
  end

  sleep REMIND_GAP
end
