require 'test_helper'

class RubyGemsControllerTest < ActionController::TestCase

  def setup
    RubyGem.delete_all
  end

  def test_show
    gem = FactoryGirl.create(:ruby_gem)
    get :show, name: gem.name
    assert_response :success
  end

  def test_not_found
    get :show, name: 'does_not_exist'
    assert_redirected_to '/404'
  end

  def test_symbol_name
    get :show, name: ':name'
    assert_redirected_to '/404'
  end

end