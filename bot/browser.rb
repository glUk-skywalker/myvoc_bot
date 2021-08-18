# frozen_string_literal: true

class Browser
  def initialize
    Selenium::WebDriver.logger.level = :error

    client = Selenium::WebDriver::Remote::Http::Default.new

    @d = Selenium::WebDriver.for(
      :chrome,
      url: 'http://chrome:4444/wd/hub',
      http_client: client,
      desired_capabilities: caps
    )
    @d.manage.timeouts.implicit_wait = 5
  end

  def get_stringified_info_for(word)
    lines = []

    lines << "<b>#{word}</b>"

    info = get_info_for(word)

    if info[:descriptions].any?
      lines << ''
      lines += info[:descriptions].map! { |d| "• #{d}" }
    end

    if info[:examples].any?
      lines << ''
      lines << 'examples:'
      lines += info[:examples].map! { |d| "• #{d}" }
    end

    if info[:translations].any?
      lines << ''
      lines << info[:translations].join(', ')
    end

    lines.join("\n")
  end

  private

  def get_info_for(word)
    info = {}

    @d.navigate.to url_for(word)
    @d.find_elements(:xpath, '//*[@class = "VK4HE"]').each(&:click)
    sleep 0.5

    elements = @d.find_elements(:xpath, '//*[@class = "fw3eif"]')
    info[:descriptions] = elements.map(&:text).compact

    elements = @d.find_elements(:xpath, '//*[@class = "AZPoqf OvhKBb"]')
    info[:examples] = elements.map(&:text).compact.map { |ex| ex.gsub(word, "<i>#{word}</i>") }

    elements = @d.find_elements(:xpath, '//*[@class = "kgnlhe"]')
    info[:translations] = elements.map(&:text).compact

    info
  end

  def url_for(word)
    "https://translate.google.com/?sl=en&tl=ru&text=#{word}&op=translate"
  end

  def caps
    prefs = {
      version: 'latest',
      chromeOptions: {
        w3c: false,
        args: [
          '--no-sandbox',
          '--disable-dev-shm-usage',
          '--no-default-browser-check',
          '--start-maximized',
          '--headless',
          '--whitelisted-ips'
        ]
      }
    }
    Selenium::WebDriver::Remote::Capabilities.chrome(prefs)
  end
end
