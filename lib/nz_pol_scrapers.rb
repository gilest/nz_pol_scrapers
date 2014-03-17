# require all files in the scrapers dir
Dir.glob("#{File.dirname(__FILE__)}/scrapers/*").each { |f| require f }