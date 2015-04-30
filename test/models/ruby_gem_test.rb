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

  def test_spec_with_special_chars
    gem_name = 'activerecord-jdbc-adapter-onsite'
    another_bad_gem = "ya2yaml"
    stub_gemspec_request(gem_name)
    stub_gemspec_request(another_bad_gem)
    RubyGem.pull_spec_and_create(gem_name)
    RubyGem.pull_spec_and_create(another_bad_gem)
    gem = RubyGem.find_by(name: gem_name)
    another = RubyGem.find_by(name: another_bad_gem)
    assert gem.info.include? "activerecord-jdbc-adapter is a database adapter for Rails\\'"
    assert_equal "Ya2YAML is \"yet another to_yaml\". It emits YAML document with complete UTF8 support (string/binary detection, \"\\u\" escape sequences and Unicode specific line breaks).\n", another.info
  end

  def test_null_dependency
    gem_name = 'cloak'
    stub_gemspec_request(gem_name)
    RubyGem.pull_spec_and_create(gem_name)
    gem = RubyGem.find_by(name: gem_name)
    assert_not_nil gem
    assert_equal 'cloak', gem.name
  end

  def test_trailing_whitespace
    stub_gemspec_request('all')
    RubyGem.pull_spec_and_create('all')
    gem = RubyGem.find_by(name: 'all')
    assert_equal 'swissmatch-street', gem.dependencies[0].name
  end


  def test_removed_dependency
    create_gem_with_dependencies('actionview', %w(activesupport builder erubis))

    stub_gemspec_request('actionview', 'actionview_removed_dep')

    assert_difference("RubyGem.find_by(name: 'actionview').dependencies.size", -1, "should be one less dependency") do
      RubyGem.pull_spec_and_create('actionview')
    end

  end

  def test_rank
    create_gem_with_dependencies('GGP', [])
    create_gem_with_dependencies('GP', ['GGP'])
    create_gem_with_dependencies('P1', ['GP'])
    create_gem_with_dependencies('P2', ['GP'])
    create_gem_with_dependencies('C1', ['P1'])
    create_gem_with_dependencies('B', [])

    ggp = RubyGem.find_by(name: 'GGP')
    ggp.rank
    assert_equal 1, ggp.direct_dependents
    assert_equal 4, ggp.total_dependents
  end

end
