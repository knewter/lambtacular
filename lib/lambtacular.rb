require 'open-uri'
require 'nokogiri'

class LambHash < Hash
  def self.[] hash
    h = self.new
    # FIXME: lol does not work for non-pathologically-shallow-hashes yet
    hash.each_pair do |key, value|
      h[key] = value
    end
    h
  end

  def [] key
    val = super(key)
    if val.respond_to?(:call)
      val.call
    else
      val
    end
  end
end

class HtmlScraperElement
  attr_accessor :url, :selector

  def initialize(url, selector)
    @url = url
    @selector = selector
  end

  def call
    # load the url
    doc = Nokogiri::HTML(open(url))
    # return the value at the selector
    doc.search(selector).first.text
  end
end

# Given a hash matching data elements to selectors, will return (well, create an
# instance var with) a nice lambhash providing 'deep structured data' based on
# the html page in question.
class HtmlScraper
  attr_accessor :url, :hash

  def initialize url, hash
    @url = url
    new_hash = LambHash.new
    hash.each_pair do |key, value|
      new_hash[key] = HtmlScraperElement.new(@url, value)
    end
    @hash = new_hash
  end
end

if __FILE__ == $0
  hash = LambHash.new
  hash[:foo] = lambda{ "bar" }
  hash[:bar] = lambda{ "foo" }
  hash[:url] = HtmlScraperElement.new('http://www.opensourceconnections.com', 'hgroup h1 span')
  hash[:whee] = "whee"
  hash

  puts "basic lambhash fun"
  puts "hash[:foo]"
  puts hash[:foo]
  puts "hash[:bar]"
  puts hash[:bar]
  puts "hash[:whee]"
  puts hash[:whee]
  puts "hash[:url]"
  puts hash[:url]

  puts "HTMLScraper"
  mapping = {
    company_name: "hgroup h1 span",
    first_article_title: "section.news li h2 a",
    first_blog_title: "section.blog li h2 a"
  }
  scraper = HtmlScraper.new("http://www.opensourceconnections.com", mapping)
  scraper.hash.each_key do |key|
    puts key
    puts scraper.hash[key]
  end
end
