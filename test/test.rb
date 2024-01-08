require 'minitest/autorun'
require 'rdf'
require 'linkeddata'
require 'shacl'

class ShaclTest < Minitest::Test
  def setup
    shapes_graph = RDF::Graph.load('../shacl/event_dates_shacl.ttl')
    @shacl = SHACL.get_shapes(shapes_graph)

  end

  def test_event_dates
    graph = RDF::Graph.load("../dump.jsonld")
    report =  @shacl.execute(graph)
    assert report.conform?
  end

end
