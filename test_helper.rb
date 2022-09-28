# require 'rubygems'
gem "selenium-webdriver"
require 'selenium-webdriver'
require 'rspec'

# include utility functions such as 'page_text', 'try_for', 'fail_safe', ..., etc.
require "#{File.dirname(__FILE__)}/agileway_utils.rb"

# this loads defined page objects under pages folder
require "#{File.dirname(__FILE__)}/pages/abstract_page.rb"
Dir["#{File.dirname(__FILE__)}/pages/*_page.rb"].each { |file| load file }

# The default base URL for running from command line or continuous build process
$BASE_URL = "https://whenwise.agileway.net"

# This is the helper for your tests, every test file will include all the operation
# defined here.
module TestHelper

  include AgilewayUtils
  if defined?(TestWiseRuntimeSupport)  # TestWise 5+
    include TestWiseRuntimeSupport 
  end

  def browser_type
    if $TESTWISE_BROWSER then
      $TESTWISE_BROWSER.downcase.to_sym
    elsif ENV["BROWSER"]
      ENV["BROWSER"].downcase.to_sym      
    else
      :chrome
    end
  end
  alias the_browser browser_type

  def site_url(default = $BASE_URL)
    $TESTWISE_PROJECT_BASE_URL || ENV["BASE_URL"] || default
  end
	
  def browser_options
    the_browser_type = browser_type.to_s

    if the_browser_type == "chrome"
      the_chrome_options = Selenium::WebDriver::Chrome::Options.new
      # make the same behaviour as Python/JS
      # leave browser open until calls 'driver.quit'
      the_chrome_options.add_option("detach", true)
      
      # if Selenium unable to detect Chrome browser in default location
      if ENV["ALTERNATIVE_CHROME_PATH"]
        the_chrome_options.binary = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
      end
          
      if $TESTWISE_BROWSER_HEADLESS || ENV["BROWSER_HEADLESS"] == "true"
        the_chrome_options.add_argument("--headless")
      end

      if defined?(TestWiseRuntimeSupport)
        browser_debugging_port = get_browser_debugging_port() rescue 19218 # default port
        puts("Enabled chrome browser debug port: #{browser_debugging_port}")
        the_chrome_options.add_argument("--remote-debugging-port=#{browser_debugging_port}")
      else
        # puts("Chrome debugging port not enabled.")
      end

      if Selenium::WebDriver::VERSION =~ /^3/
        if defined?(TestwiseListener)
          return :options => the_chrome_options, :listener => TestwiseListener.new      
        else 
          return :options => the_chrome_options      
        end
      else       
        if defined?(TestwiseListener)
          return :capabilities => the_chrome_options, :listener => TestwiseListener.new      
        else 
          return :capabilities => the_chrome_options      
        end
      end
      
    elsif the_browser_type == "firefox"
      the_firefox_options = Selenium::WebDriver::Firefox::Options.new
      the_firefox_options = Selenium::WebDriver::Firefox::Options.new
      if $TESTWISE_BROWSER_HEADLESS || ENV["BROWSER_HEADLESS"] == "true"
        the_firefox_options.headless!
        # the_firefox_options.add_argument("--headless") # this works too
      end
      
      # the_firefox_options.add_argument("--detach") # does not work
      
      return :options => the_firefox_options

    elsif the_browser_type == "ie"
      the_ie_options = Selenium::WebDriver::IE::Options.new
      if $TESTWISE_BROWSER_HEADLESS || ENV["BROWSER_HEADLESS"] == "true"
        # not supported yet?
        # the_ie_options.add_argument('--headless')
      end
      return :options => the_ie_options

    elsif the_browser_type == "edge"
      the_edge_options = Selenium::WebDriver::Edge::Options.new
      the_edge_options.add_option("detach", true)
      
      if $TESTWISE_BROWSER_HEADLESS || ENV["BROWSER_HEADLESS"] == "true"
        the_edge_options.add_argument("--headless")
      end

      if defined?(TestWiseRuntimeSupport)
        browser_debugging_port = get_browser_debugging_port() rescue 19218 # default port
        puts("Enabled edge browser debug port: #{browser_debugging_port}")
        the_edge_options.add_argument("--remote-debugging-port=#{browser_debugging_port}")
      else
        # puts("Chrome debugging port not enabled.")
      end
      
      return  {  :capabilities =>  the_edge_options }
      
    else
      return {}
    end
  end
	
  def driver
    @driver
  end
  
  def browser
    @driver
  end
  
  
  # got to path based on current base url
  def visit(path)
    driver.navigate.to(site_url + path)
  end
  
  def page_text
    driver.find_element(:tag_name => "body").text
  end
  
  def debugging?
    return ENV["RUN_IN_TESTWISE"].to_s == "true" && ENV["TESTWISE_RUNNING_AS"] == "test_case"
  end
  
  ## 
  #  Highlight a web control on a web page,currently only support 'background_color'
  #  - elem,
  #  - options, a hashmap, 
  #      :background_color
  #      :duration,  in seconds 
  #  
  #  Example:
  #   highlight_control(driver.find_element(:id, "username"), {:background_color => '#02FE90', :duration => 5})
  def highlight_control(element, opts={})
    return if element.nil?
    background_color = opts[:background_color] ? opts[:background_color] : '#FFFF99'
    duration = (opts[:duration].to_i * 1000) rescue 2000
    duration = 2000 if duration < 100 || duration > 60000
    driver.execute_script("h = arguments[0]; h.style.backgroundColor='#{background_color}'; window.setTimeout(function () { h.style.backgroundColor = ''}, #{duration})", element)  
  end
  
  # prevent extra long string generated test scripts that blocks execution when running in 
  # TestWise or BuildWise Agent
  def safe_print(str)
    return if str.nil? || str.empty?
    if (str.size < 250)
      puts(str)
      return;
    end
    
    if ENV["RUN_IN_TESTWISE"].to_s == "true" && ENV["RUN_IN_BUILDWISE_AGENT"].to_s == "true"
      puts(str[0..200])
    end
  end
  
  
  ## user defined functions
  #


end
