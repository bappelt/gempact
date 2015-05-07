module RubyGemsHelper
  def format_score(score)
    if score
      %Q[
          <strong class="score" data-tooltip title="As of: #{@ruby_gem.ranked_at.to_s(:short)}">
            #{number_with_precision(score, delimiter: ',', precision: 0)}
          </strong>
        ].html_safe
    else
      '?'
    end
  end
end
