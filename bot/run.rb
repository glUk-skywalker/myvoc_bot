# frozen_string_literal: true

require_relative 'requires'

Linguo.api_key = 'demo'
token = ENV['BOT_TOKEN']

words = Words.new
browser = Browser.new

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::Message
      case message.text
      when '/go'
        word = words.pick!.get(:word)
        defs = browser.get_info_for(word)
        defs.map! { |d| "• #{d}" }
        bot.api.send_message(chat_id: message.from.id, text: "#{word}\n#{defs.join("\n")}\n---\nwords active: #{words.active.count} (of #{words.count})")
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
