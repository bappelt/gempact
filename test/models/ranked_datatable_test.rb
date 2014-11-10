require 'test_helper'

class RankedDatatableTest < ActiveSupport::TestCase

  def setup
    RubyGem.delete_all
    %w(gem1 gem2 gem3).each { |name| RubyGem.create(name: name, total_dependents: 0) }
    RubyGem.create(name: 'unscored_gem')
    @rdt = RankedDatatable.new(OpenStruct.new)
  end


  def test_data
    @rdt.view.params = {search: {value: ''}, start: 0}
    assert_equal 3, @rdt.as_json[:data].size
    %w(gem1 gem2 gem3).each { |name|
      assert @rdt.as_json[:data].find {|entry| entry[:name]==name }
    }
    refute @rdt.as_json[:data].find {|entry| entry[:name]=='unscored_gem' }
  end

  def test_data_with_search
    @rdt.view.params = {search: {value: 'gem1'}, start: 0}
    assert_equal 1, @rdt.as_json[:data].size
    assert_equal 'gem1', @rdt.as_json[:data][0][:name]
  end

end