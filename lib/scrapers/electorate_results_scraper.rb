# encoding: utf-8

module NZPolScrapers
  class ElectorateResultsScraper
    require 'nokogiri'
    require 'open-uri'
    require 'yaml'

    def self.scrape_to_files(directory)
      scrape do |parsed_rows, electorate|
        year = parsed_rows.first[:candidacy][:year]
        file = File.new("#{directory}/#{electorate[:name]} #{year}.yml", "w")
        file.puts parsed_rows.to_yaml
        file.close
      end
    end

    def self.scrape_to_hash
      result = {}
      scrape do |parsed_rows, electorate|
        result[:"#{electorate[:name]}"] = { :"#{parsed_rows.first[:candidacy][:year]}" => parsed_rows }
      end
      result
    end

    private

    def self.scrape(&block)
      # loop through each of the electorates
      # we load them from wikipedia too see: electorate_scraper.rb
      NZPolScrapers::ElectorateScraper.scrape_to_array.each do |electorate|
        election_result_tables = election_result_tables_for(electorate)
        # within each table get yer parse on
        election_result_tables.each do |election_result_table|
          parsed_rows = parsed_rows_from_election_result_table(election_result_table, electorate)
          yield parsed_rows, electorate
        end
      end
      # and we're done :)
    end

    def self.election_result_tables_for(electorate)
      # load up the main content of the wikipedia page
      doc = Nokogiri::HTML(open(electorate[:url])).at_css('#mw-content-text')
      # find all the tables representing election results
      election_result_tables = doc.css('table[border="1"]')
    end

    def self.parsed_rows_from_election_result_table(election_result_table, electorate)
      year = election_result_table.children.first.children.first.children.first.attributes['title'].value.split(' ').last

      puts "Scraping results for #{electorate[:name]}, #{year}"

      table_title = election_result_table.children.first.children.text
      election_type = table_title =~ /by\-election/ ? 'by-election' : 'general'

      # A candidacy is an instance of a candidate seeking election in an electorate
      candidacy_rows = election_result_table.css('tr.vcard')

      parsed_rows = []

      candidacy_rows.each do |candidacy_row|
        # don't parse anything if the fourth child is all blank text, this means there is no candidate name or vote information
        unless candidacy_row.children[4].children.text.empty?
          parsed_row = { party: party_for_candidacy_row(candidacy_row), 
                        candidate: candidate_for_candidacy_row(candidacy_row), 
                        candidacy: candidacy_for_candidacy_row(candidacy_row, year, electorate[:name], election_type)
                      }
          parsed_rows << parsed_row
          puts "...parsed #{parsed_row[:candidate][:name]} of #{parsed_row[:party][:name]}"
        end
      end

      parsed_rows
    end

    def self.party_for_candidacy_row(candidacy_row)
      party = {}
      party[:colour] = candidacy_row.children.first.attributes['style'].value.split(';').first.split(' ').last
      party[:name] = party_name_for_candidacy_row(candidacy_row)
      party[:short_name] = short_party_name_for_candidacy_row(candidacy_row)
      party
    end

    def self.candidate_for_candidacy_row(candidacy_row)
      candidate = {}
      candidacy_row.children[4].css('img').remove # remove any image tags from within the name cell
      candidacy_row.children[4].css('sup').remove # remove any superscript tags from within the name cell
      name = candidacy_row.children[4].children.text
      cut_bullshit_from(name)
      candidate[:name] = name
      split_name = candidate[:name].split(' ')
      candidate[:last_name] = split_name.pop
      candidate[:first_name] = split_name.join(' ')
      candidate
    end

    def self.candidacy_for_candidacy_row(candidacy_row, year, electorate, election_type)
      candidacy = {}
      candidacy[:votes] = candidacy_row.children[6].text.delete(',').to_i
      candidacy[:percent] = candidacy_row.children[8].text.to_f
      candidacy[:electorate] = electorate
      candidacy[:year] = year
      candidacy[:election_type] = election_type
      candidacy
    end

    def self.party_name_for_candidacy_row(candidacy_row)
      # some cells contain links, others don't, so we need to get different values depending on what's there
      unless candidacy_row.children[2].children.first.attributes['title'].nil?
        name = candidacy_row.children[2].children.first.attributes['title'].value
      else
        name = candidacy_row.children[2].children.first.text
      end
      cut_bullshit_from(name)
    end

    def self.short_party_name_for_candidacy_row(candidacy_row)
      # likewise for the regular party name, in some cases there is only one name so we must fall back
      unless candidacy_row.children[2].children.last.children.text == ''
        name = candidacy_row.children[2].children.last.children.text
      else
        name = candidacy_row.children[2].children.last.text
      end
      cut_bullshit_from(name)
    end

    def self.cut_bullshit_from(name)
      bullshits = [' (New Zealand)',
                   ' (New Zealand political party)',
                   ' (politician)',
                   ' (page does not exist)',
                   ' (political party)',
                   'Y ',
                   'N ',
                   '[note 1]']
      bullshits.each {|bullshit| name.slice! bullshit }
      name
    end

  end
end