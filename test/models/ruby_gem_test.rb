require 'test_helper'

class RubyGemTest < ActiveSupport::TestCase

  def setup
   Neo4j::Session.query(  %Q{
                              MATCH (n)
                              OPTIONAL MATCH (n)-[r]-()
                              DELETE n,r
                            }
                        )
  end


  def test_pull_spec_and_create

    data = File.open('test/data/actionview.json').read

    stub_request(:get, "https://rubygems.org/api/v1/gems/actionview.json").
      with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => data, :headers => {})

    RubyGem.pull_spec_and_create('actionview')
    assert_equal 4, RubyGem.all.count
    action_view = RubyGem.find_by(name: 'actionview')
    assert_not_nil action_view
    assert_equal 'actionview', action_view.name
    dependency_names = action_view.dependencies.collect { |d| d.name }
    assert_equal %w(activesupport builder erubis), dependency_names.sort

  end


end
