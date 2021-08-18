# frozen_string_literal: true

require_relative 'requires'

def log(msg)
  msg = "#{Time.now}\t#{msg}"
  puts msg
  File.open('/data/mainbot.log', 'a') { |f| f.puts msg }
end

Linguo.api_key = 'demo'
token = ENV['BOT_TOKEN']

log 'bot started!'
log 'seleeping some time to ensure the browser is started..'
sleep 15 # wait while chrome is starting

words = Words.new
browser = Browser.new

log 'initialization is done! listening..'
Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    log "a message!! #{message.text}"
    case message
    when Telegram::Bot::Types::Message

      log 'words uniqing..'
      words.uniq!

      case message.text
      when '/go'
        log 'picking a word..'
        word = words.pick!.get(:word)
        begin
          log "getting info for '#{word}'.."
          msg = browser.get_stringified_info_for(word)
        rescue => e
          log "whoops!! something went wrong while getting the word info :("
          log e.message
          log 'inititating a new borwser..'
          browser = Browser.new
          retry
        end

        msg += "\n---\nwords active: #{words.active.count} (of #{words.count})"

        begin
          log "sending info for '#{word}'.."
          bot.api.send_message(chat_id: message.from.id, text: msg, parse_mode: 'html')
          log 'sent!'
        rescue => e
          log "whoops! something went wrong while sending the message :("
          log e.message
          retry
        end
      else
        if message.text.lang.first != 'en'
          bot.api.send_message(
            chat_id: message.from.id,
            text: 'this word does not look like an English word'
          )
          next
        end

        if words.presents?(message.text)
          bot.api.send_message(
            chat_id: message.from.id,
            text: "'#{message.text}' already in the dictionary"
          )
          next
        end

        word = message.text.downcase
        words.add_word(word)
        bot.api.send_message(
          chat_id: message.from.id,
          text: "'#{word}' has been added to the dictionary\n\nwords count: #{words.count}"
        )
      end
    end
  end
end
