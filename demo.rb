#!/usr/bin/env ruby

require 'linkeddata'

# creating an array of urls
urls = Array.new
urls << "https://scenesfrancophones.ca/spectacles/raphael-butler-4082"
urls << "https://scenesfrancophones.ca/spectacles/philippe-laprise-4064"
urls << "https://scenesfrancophones.ca/spectacles/baie-4054"

# creating the graph instance
graph = RDF::Graph.new

# looping through each url
urls.each do |url|
  begin
    graph << RDF::Graph.load(url)
  rescue  StandardError => e
    puts "Rescue: #{e.message}"
  end
end

# info about the graph
puts "Graph is an instance of class #{graph.class}"
puts "Graph contains #{graph.count} triples."
puts "Graph contains: #{graph.query([nil, RDF::type, RDF::Vocab::SCHEMA.Event]).count} events", ""
events = graph.query([nil, RDF::type, RDF::Vocab::SCHEMA.Event]).each.subjects
puts "List of events URIs:"
events.each { |event| puts event }
puts "The name of the first event:",
  graph.query([events.first, RDF::Vocab::SCHEMA.name, nil]).each.objects, ""

sparql = './sparql/fix-date.sparql'
graph = graph.query(SPARQL.parse(File.read(sparql), update: true))

File.write('dump.jsonld', graph.dump(:jsonld))
# puts graph.dump(:turtle)
