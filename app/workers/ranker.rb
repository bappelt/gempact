class Ranker

  @queue = :ranking_queue

  def self.perform(gem_name)
    gem = RubyGem.find_by(name: gem_name)
    gem.rank
  end

end