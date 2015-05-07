class Datatable
  attr_reader :view
  delegate :params, :h, :link_to, :url_for, to: :view

  def initialize(view)
    @view = view
  end

  def page_start
    params[:start].to_i
  end

  def per_page
    if params[:length].to_i > 0
      [params[:length].to_i, 100].min
    else
      10
    end
  end

  def sort_direction
    params[:order]['0'][:dir]
  rescue NoMethodError
    'desc'
  end

  def sort_column
    col_index = params[:order]['0'][:column]
    params[:columns][col_index.to_s][:data]
  rescue NoMethodError
    'total_dependents'
  end
end
