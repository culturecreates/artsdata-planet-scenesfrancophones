require 'nokogiri'
require 'open-uri'
require 'linkeddata'

page_url = "https://scenesfrancophones.ca/spectacles?page="
base_url = "https://scenesfrancophones.ca"
max_retries, retry_count, page_number = 3, 0, 1
graph = RDF::Graph.new
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
  entities_data = main_doc.css('div.title')
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
      graph << RDF::Graph.load(entity)
    rescue StandardError => e
      puts "Error loading RDF from #{entity}: #{e.message}"
    end
  end
  page_number += 1
  retry_count = 0
end

File.open('events.jsonld', 'w') do |file|
  file.puts(graph.dump(:jsonld))
end