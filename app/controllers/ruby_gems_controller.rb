class RubyGemsController < ApplicationController
  def index
    @ruby_gems = RubyGem.take(50)
  end

  def show
    @ruby_gem = RubyGem.find_by!(name: params[:name])
  end
end
