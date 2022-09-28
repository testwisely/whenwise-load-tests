load File.dirname(__FILE__) + "/../test_helper.rb"
load File.dirname(__FILE__) + "/../load_test_helper.rb"

describe "Load - Repeat Login" do
  include TestHelper
  include LoadTestHelper

  before(:all) do
    @driver = $driver = Selenium::WebDriver.for(browser_type, browser_options)
    log_time("Visit Home Page") {
      @driver.navigate.to(site_url)
    }
  end

  before(:each) do
  end

  after(:all) do
    dump_timings
    @driver.quit unless debugging?
  end

  it "Sign in repeatly" do
    load_test_repeat.times do
      log_time("Visit Home Page") { visit("/") }
      log_time("Visit Login Page") { driver.find_element(:link, "SIGN IN").click }
      driver.find_element(:id, "email").send_keys("james@client.com")
      driver.find_element(:id, "password").send_keys("test01")
      log_time("Sign in") {
        driver.find_element(:id, "login-btn").click
        driver.find_element(:id, "profile-dropdown") # verify user profile icon
      }
      log_time("Sign out") { visit("/sign-out") }
    end
  end
end
