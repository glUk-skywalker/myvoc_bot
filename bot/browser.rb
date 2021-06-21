# frozen_string_literal: true

class Browser
  def initialize
    @d = Selenium::WebDriver.for(
      :remote,
      url: 'http://chrome:4444/wd/hub',
      http_client: Selenium::WebDriver::Remote::Http::Default.new,
      desired_capabilities: caps
    )
    @d.manage.timeouts.implicit_wait = 10
  end

  def get_stringified_info_for(word)
    lines = [word]
    lines << ''

    info = get_info_for(word)

    lines += info[:descriptions].map! { |d| "• #{d}" }

    lines << ''
    lines << 'examples:'
    lines += info[:examples].map! { |d| "• #{d}" }

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
    info[:examples] = elements.map(&:text).compact

    info
  end

  def url_for(word)
    "https://translate.google.com/?sl=en&tl=ru&text=#{word}&op=translate"
  end

  def caps
    prefs = {
      version: 'latest',
      chromeOptions: {
        w3c: false
      }
    }
    Selenium::WebDriver::Remote::Capabilities.chrome(prefs)
  end
end
