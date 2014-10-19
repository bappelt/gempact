class RubyGemsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_action :load_ruby_gem, only: [:show, :dependents_count, :transitive_dependents_count]

  def index
  end

  def show
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
    @ruby_gem = RubyGem.find_by!(name: params[:name])
  end
end
