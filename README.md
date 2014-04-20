# NZPolScrapers

Wikipedia scrapers which parse information about NZ politics.

Just want the data? Check the data directory of this repository.

## Installation

Add this line to your application's Gemfile:

`gem 'nz_pol_scrapers'`

And then execute:

`$ bundle`

## Usage

### NZPolScrapers::ElectorateResultsScraper

This scraper retrieves electorate election results from Wikipedia.

Included is a data point for each 'candidacy' (an instance of a candidate seeking election in an electorate) formatted as follows.

```ruby
{ 
  party: { name: 'Green Party of Aotearoa New Zealand', short_name: 'Green'. colour: '#098137' },
  candidate: { name: 'Nándor Tánczos', first_name: 'Nándor', last_name: 'Tánczos' },
  candidacy: { votes: 3057, percent: 9.37, electorate: 'Auckland Central', year: 1999, election_type: 'general' }
}
```

#### scrape_to_files

Scrapes and saves data in a file in the specified directory.

```ruby	
directory = '/Users/giles/scrape/electorate_results/'
NZPolScrapers::ElectorateResultsScraper.scrape_to_files(directory)
```
    
Running this will result in:

    $ ls /Users/giles/scrape/electorate_results/
	Auckland Central 1996.yml
	Auckland Central 1999.yml
	Auckland Central 2002.yml
	Auckland Central 2005.yml
	...
	
#### scrape_to_hash

Scrapes and returns a hash.

```ruby
NZPolScrapers::ElectorateResultsScraper.scrape_to_hash
=> {:party=>{:colour=>"#098137", :name=>"Green Party of Aotearoa New Zealand", :short_name=>"Green"}...
```

### NZPolScrapers::ElectorateScraper

This scraper retrieves the names of all electorates in New Zealand from Wikipedia.

#### scrape_to_files

Scrapes and saves data in a file in the specified directory.

```ruby	
directory = '/Users/giles/scrape/electorates/'
NZPolScrapers::ElectorateScraper.scrape_to_files(directory)
```
    
Running this will result in:

    $ ls /Users/giles/scrape/electorates/
    NZ Electorates.yml        

#### scrape_to_array

Scrapes and returns an array of hashes with two keys, `:name` and `:url` which respectively contain the name and wikipedia url of the electorate.

```ruby
NZPolScrapers::ElectorateScraper.scrape_to_array
=> [{:name=>"Auckland Central", :url=>"http://en.wikipedia.org/wiki/Auckland_Central_(New_Zealand_electorate)"}...
```

#### scrape_to_hash

Scrapes and returns a hash. The array is probably easier to use in most cases.

```ruby
NZPolScrapers::ElectorateScraper.scrape_to_hash
 => {:"Auckland Central"=>{:name=>"Auckland Central", :url=>"http://en.wikipedia.org/wiki/Auckland_Central...
```
