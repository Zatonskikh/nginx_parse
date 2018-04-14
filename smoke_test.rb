require 'selenium/webdriver'
require 'selenium/webdriver/common/wait'

class SimpleTest
  def initialize(url)
    @driver = Selenium::WebDriver.for :chrome, switches: %w[--disable-infobars]
    @url = url
    @wait = Selenium::WebDriver::Wait.new(timeout: 15)
  end

  def go_to_site
    @driver.get @url
    open_login_window
    input_credentials
    open_profile
    log_out
    @driver.close
  end

  def open_login_window
    log_in = @driver
             .find_element(id: 'topMenu_login')
    @wait.until do
      log_in if log_in.displayed?
    end
    log_in.click
    @wait.until do
      element = @driver.find_element(id: 'SocialRegAuth')
      element if element.displayed?
    end
  end

  def input_credentials
    @driver
      .find_element(id: 'input_auth_email')
      .send_keys('tyrpyx@gmail.com')
    @driver
      .find_element(id: 'input_auth_pas')
      .send_keys('XxMyV3ryT3stP4ssw0rd!1')
    @driver
      .find_element(xpath: '//*[@id="SocialAuth"]/div[5]')
      .click
    @wait.until do
      is_user_displayed = @driver.page_source.include?('tyrpyx')
      if is_user_displayed
        puts 'Logged in'
        is_user_displayed
      end
    end
  end

  def open_profile
    @driver
      .find_element(xpath: '//*[@id="layout_panels"]/header/div/div/div/span')
      .click
    profile = @driver.find_element(id: 'topMenu_profile')
    @wait.until do
      profile if profile.displayed?
    end
    profile.click
    @wait.until do
      element = @driver.page_source.include?('Личный кабинет')
      element
    end
  end
  
  def log_out
    @driver
      .find_element(xpath: '//*[@id="layout_panels"]/header/div/div/div/span')
      .click
    exit = @driver.find_element(id: 'topMenu_logout')
    @wait.until do
      exit if exit.displayed?
    end
    exit.click
    @wait.until do
      log_in = @driver.page_source.include?('Войти')
      log_in
    end
    puts 'Test passed'
  end
end

if $PROGRAM_NAME == __FILE__
  SimpleTest.new('https://www.onetwotrip.com/').go_to_site
end