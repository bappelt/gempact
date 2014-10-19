class TransitiveDependentsDatatable < Datatable
  def as_json(options = {})
    {
      draw: params[:draw],
      recordsTotal: total_count,
      data: data
    }
  end

  def data
    RubyGem.find_transitive_dependents(ruby_gem.name,
                                       search: params[:search][:value],
                                       limit: per_page,
                                       offset: page_start)
    .map do |result|
      {
        name: result.dependent.name
      }
    end
  end

  private

  def ruby_gem
    @ruby_gem ||= RubyGem.find_by!(name: params[:ruby_gem])
  end

  def total_count
    key = "gems/#{ruby_gem.name}/transitive_dependents/count"
    Rails.cache.fetch(key) {
      puts "=============================================="
      puts "Filling cache for #{key}"
      puts "=============================================="

      RubyGem.count_transitive_dependents(ruby_gem.name)
    }
  end
end
