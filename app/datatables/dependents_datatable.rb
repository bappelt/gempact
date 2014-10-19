class DependentsDatatable < Datatable
  def as_json(options = {})
    {
      draw: params[:draw],
      recordsTotal: query.count,
      data: format(filter(query))
    }
  end

  def query
    @query ||= RubyGem.find_by(name: params[:ruby_gem]).dependents
  end

  def filter(query)
    if params[:search][:value].present?
      regex = Regexp.new(".*#{params[:search][:value]}.*")
      query = query.where(name: regex)
    end
    query.limit(per_page).offset(page_start)
  end

  def format(query)
    query.map { |gem|
      {
        name: gem.name
      }
    }
  end
end
