load File.dirname(__FILE__) + '/../test_helper.rb'
load File.dirname(__FILE__) + '/../load_test_helper.rb'

describe "Test Suite" do
    include TestHelper
    include LoadTestHelper

    before(:all) do
      # browser_type, browser_options, site_url are defined in test_helper.rb
      @driver = $driver = Selenium::WebDriver.for(browser_type, browser_options)
      driver.manage().window().resize_to(1280, 720)
      log_time("Visit Home Page") { driver.get(site_url) }
    end

    after(:all) do
      dump_timings
      driver.quit unless debugging?
    end

    it "Test Case Name" do
      load_test_repeat.times do      
        # driver.find_element(...)
        # expect(page_text).to include(..)
      end
    end

end
