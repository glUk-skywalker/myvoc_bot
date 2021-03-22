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

  def get_info_for(word)
    @d.navigate.to url_for(word)
    elements = @d.find_elements(:xpath, '//*[@class = "fw3eif"]')
    elements.map(&:text).compact
  end

  private

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
