class DatatablesController < ApplicationController
  def dependents
    render json: DependentsDatatable.new(view_context)
  end

  def transitive_dependents
    render json: TransitiveDependentsDatatable.new(view_context)
  end
end
