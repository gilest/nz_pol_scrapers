# encoding: utf-8

module NZPolScrapers
  class ElectorateScraper
    require 'nokogiri'  
    require 'open-uri'
    require 'yaml'

    def self.scrape_to_files(directory)
      result = scrape_to_hash
      file = File.new("#{directory}/NZ Electorates.yml", "w")
      file.puts result.to_yaml
      file.close
    end

    def self.scrape_to_hash
      result = {}
      scrape do |name, url|
        result[:"#{name}"] = { name: name, url: url }
      end
      result
    end

    def self.scrape_to_array
      result = []
      scrape do |name, url|
        result << { name: name, url: url }
      end
      result
    end

    private

    def self.scrape(&block)
      # visit the nz electorates index on wikipedia
      url = 'http://en.wikipedia.org/wiki/Category:New_Zealand_electorates'
      doc = Nokogiri::HTML(open(url)).at_css('#mw-pages')

      # select all the category links
      links = doc.css('li a')

      # load up the electorate page addresses and names into an array of hashes
      electorates = []
      links.each do |link|
        name = clean_electorate_name(link.attributes['title'].value)
        url = "http://en.wikipedia.org#{link.attributes['href'].value}"
        yield name, url unless name == 'New Zealand electorates'
      end
    end

    def self.clean_electorate_name(name)
      name.slice! ' (New Zealand electorate)'
      name
    end

  end
end