class GithubImporter

  @queue = :github_repos

  def self.perform(full_repo_name)
    RubyProject.create_from_gh(full_repo_name)
  end

end