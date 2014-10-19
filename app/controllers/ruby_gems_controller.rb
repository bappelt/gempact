class RubyGemsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_action :load_ruby_gem, only: [:show, :dependents_count, :transitive_dependents_count]

  def index
  end

  def show
  end

  def dependents_count
    count = @ruby_gem.dependents.count
    respond_to do |format|
      format.html { render text: number_with_precision(count, delimiter: ',', precision: 0) }
    end
  end

  def transitive_dependents_count
    key = "gems/#{@ruby_gem.name}/transitive_dependents/count"
    count = Rails.cache.fetch(key) {
      RubyGem.count_transitive_dependents(@ruby_gem.name)
    }
    respond_to do |format|
      format.html { render text: number_with_precision(count, delimiter: ',', precision: 0) }
    end
  end

  private

  def load_ruby_gem
    @ruby_gem = RubyGem.find_by!(name: params[:name])
  end
end
