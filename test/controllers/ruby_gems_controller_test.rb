require 'test_helper'

class RubyGemsControllerTest < ActionController::TestCase
  setup do
    @ruby_gem = ruby_gems(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ruby_gems)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ruby_gem" do
    assert_difference('RubyGem.count') do
      post :create, ruby_gem: {  }
    end

    assert_redirected_to ruby_gem_path(assigns(:ruby_gem))
  end

  test "should show ruby_gem" do
    get :show, id: @ruby_gem
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ruby_gem
    assert_response :success
  end

  test "should update ruby_gem" do
    patch :update, id: @ruby_gem, ruby_gem: {  }
    assert_redirected_to ruby_gem_path(assigns(:ruby_gem))
  end

  test "should destroy ruby_gem" do
    assert_difference('RubyGem.count', -1) do
      delete :destroy, id: @ruby_gem
    end

    assert_redirected_to ruby_gems_path
  end
end
