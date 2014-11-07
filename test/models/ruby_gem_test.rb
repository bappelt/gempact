require 'test_helper'

class RubyGemTest < ActiveSupport::TestCase

  def setup
    Neo4j::Session.query(%Q{
                              MATCH (n)
                              OPTIONAL MATCH (n)-[r]-()
                              DELETE n,r
                            }
    )
  end


  def test_pull_spec_and_create

    stub_gemspec_request('actionview')

    RubyGem.pull_spec_and_create('actionview')
    assert_equal 4, RubyGem.all.count
    action_view = RubyGem.find_by(name: 'actionview')
    assert_not_nil action_view
    assert_equal 'actionview', action_view.name
    dependency_names = action_view.dependencies.collect { |d| d.name }
    assert_equal %w(activesupport builder erubis), dependency_names.sort

  end

  def test_removed_dependency
    create_gem_with_dependencies('actionview', %w(activesupport builder erubis))

    stub_gemspec_request('actionview', 'actionview_removed_dep')

    assert_difference("RubyGem.find_by(name: 'actionview').dependencies.size", -1, "should be one less dependency") do
      RubyGem.pull_spec_and_create('actionview')
    end

  end

end
