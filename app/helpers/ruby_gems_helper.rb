module RubyGemsHelper
  def format_score(score)
    if score
      number_with_precision(score, delimiter: ',', precision: 0)
    else
      '?'
    end
  end
end
