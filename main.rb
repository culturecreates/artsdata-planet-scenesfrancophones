require 'nokogiri'
require 'open-uri'
require 'linkeddata'

if ARGV.length != 4
  puts "Usage: ruby script_name.rb <page_url> <base_url> <entity_identifier> <file_name>"
  exit
end

page_url = ARGV[0]
base_url = ARGV[1]
entity_identifier = ARGV[2]
file_name = ARGV[3]
max_retries, retry_count, page_number = 3, 0, 1
graph = RDF::Graph.new
threads = []

loop do
  url = "#{page_url}#{page_number}"
  begin
    main_page_html_text = URI.open(url).read
  rescue StandardError => e
    retry_count += 1
    if retry_count < max_retries
      retry
    else
      puts "Max retries reached. Unable to fetch the content for page #{page_number}."
      break
    end
  end

  main_doc = Nokogiri::HTML(main_page_html_text)
  entities_data = main_doc.css(entity_identifier)
  entity_urls = []
  entities_data.each do |entity|
    href = entity.css('a')[0]['href']
    entity_urls << base_url+href
  end

  if entity_urls.empty?
    puts "No more entities found on page #{page_number}. Exiting..."
    break
  end

  entity_urls.each do |entity|
    begin
      threads << Thread.new {graph << RDF::Graph.load(entity)}
    rescue StandardError => e
      puts "Error loading RDF from #{entity}: #{e.message}"
    end
  end
  page_number += 1
  retry_count = 0
end
threads.each(&:join) 

File.open(file_name, 'w') do |file|
  file.puts(graph.dump(:jsonld))
end