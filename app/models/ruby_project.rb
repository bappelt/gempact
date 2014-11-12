class RubyProject
  include Neo4j::ActiveNode

  property :name

  has_many :out, :dependencies, model_class: RubyGem, type: 'depends_on'

  def self.find_or_create_by_name(full_repo_name)
    project = RubyProject.find_by(name: full_repo_name)
    project = RubyProject.create(name: full_repo_name) unless project.present?
    project
  end

  def self.create_from_gh(full_repo_name)
    gh_client = GitHubClient.new
    project = RubyProject.find_or_create_by_name(full_repo_name)
    gem_deps = []
    gh_client.get_gem_dependencies(full_repo_name).each do |gem_name|
      gem_deps << RubyGem.find_by(name: gem_name)
    end
    project.dependencies = gem_deps
    project.save!
    project
  end

end