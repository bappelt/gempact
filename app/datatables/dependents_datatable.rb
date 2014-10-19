class DependentsDatatable < Datatable
  def as_json(options = {})
    {
      draw: params[:draw],
      recordsTotal: total_count,
      recordsFiltered: filtered_count,
      data: data
    }
  end

  private

  def ruby_gem
    @ruby_gem ||= RubyGem.find_by(name: params[:ruby_gem])
  end

  def total_count
    key = "gems/#{ruby_gem.name}/dependents/count"
    Rails.cache.fetch(key) {
      RubyGem.count_dependents(ruby_gem.name)
    }
  end

  def filtered_count
    search = params[:search][:value]
    key = "gems/#{ruby_gem.name}/dependents/count/search/#{search}"
    Rails.cache.fetch(key) {
      RubyGem.count_dependents(ruby_gem.name, search: search)
    }
  end

  def data
    RubyGem.find_dependents(ruby_gem.name,
      search: params[:search][:value],
      limit: per_page,
      offset: page_start
    ).map do |result|
      {
        name: result.dependent.name
      }
    end
  end
end
