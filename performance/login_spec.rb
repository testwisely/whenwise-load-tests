load File.dirname(__FILE__) + "/../test_helper.rb"
load File.dirname(__FILE__) + "/../load_test_helper.rb"
require "mechanize"

describe "Login" do
  include TestHelper
  include LoadTestHelper

  before(:all) do
    @browser = ::Mechanize.new
  end

  after(:all) do
    dump_timings
  end

  it "Test Case Name" do
    log_time("Visit home page") { @browser.get(site_url) }
    log_time("Visit login page") { @browser.get(site_url + "/sign-in") }
    login_form = @browser.page.forms.first
    login_form.field_with(name: "session[email]").value = "driving@biz.com"
    login_form.field_with(:name => "session[password]").value = "test01"
    log_time("Login") {
      @browser.submit(login_form, login_form.button_with(:id => "sign-in-btn"))
    }
  end
end
