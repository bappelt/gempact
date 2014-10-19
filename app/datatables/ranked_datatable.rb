class RankedDatatable < Datatable
  def as_json(options = {})
    {
      draw: params[:draw],
      recordsTotal: total_count,
      recordsFiltered: filtered_count,
      data: data
    }
  end

  private

  def total_count
    RubyGem.count
  end

  def filtered_count
    Neo4j::Session.query("MATCH (g:RubyGem) #{search_expr} RETURN COUNT(g) AS total_count").first.total_count
  end

  def search_expr
    params[:search][:value].blank? ? '' : "WHERE dependent.name =~ '.*#{params[:search][:value]}.*' "
  end

  def data
    Neo4j::Session.query(
      "MATCH (gem:RubyGem) #{search_expr} RETURN gem ORDER BY gem.total_dependents DESC " +
      "SKIP #{page_start} LIMIT #{per_page}"
    ).map do |result|
      {
        name: result.gem.name,
        score: result.gem.total_dependents
      }
    end
  end
end
