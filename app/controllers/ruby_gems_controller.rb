class RubyGemsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_action :load_ruby_gem, only: [:show, :dependents_count, :transitive_dependents_count]

  def index
  end

  def show
    histories = []
    GemHistory.all(gem_name: @ruby_gem.name).each { |h| histories += h.total_dependent_counts }
    @histories = histories.collect { |h| [ h['timestamp'], h['count']]}
  end

  def badge
    gem = RubyGem.find_by!(name: params[:name])
    formatted_score = number_with_delimiter(gem.gempact_score)
    redirect_to "http://img.shields.io/badge/GemPact%20Factor-#{formatted_score}-blue.svg"
  end

  def badge_home
    @ruby_gem = RubyGem.find_by!(name: params[:name])
  end

  def dependents_count
    count = @ruby_gem.direct_dependents
    respond_to do |format|
      format.html { render text: number_with_precision(count, delimiter: ',', precision: 0) }
    end
  end

  def transitive_dependents_count
    count = @ruby_gem.total_dependents
    respond_to do |format|
      format.html { render text: number_with_precision(count, delimiter: ',', precision: 0) }
    end
  end

  private

  def load_ruby_gem
    @ruby_gem = RubyGem.find_by(name: params[:name])
    redirect_to '/404'  if @ruby_gem.nil?
  end
end
