# frozen_string_literal: true

require 'telegram/bot'

TIME_FILEPATH = '/data/backup.time'
token = ENV['BOT_TOKEN']

def backup_now?
  last_time = Time.parse File.read(TIME_FILEPATH)
  (Time.now - last_time) > 60 * 60 * 24
rescue
  true
end

loop do
  sleep 1
  next unless backup_now?

  Telegram::Bot::Client.run(token) do |bot|
    bot.api.send_document(
      chat_id: ENV['CHAT_ID'],
      document: Faraday::UploadIO.new('/data/my-database.db', 'application/sql')
    )

    File.open(TIME_FILEPATH, 'w') { |f| f.write Time.now.to_s }
  end
end
