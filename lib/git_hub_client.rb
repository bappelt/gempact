class GitHubClient

  def initialize
    @client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
  end

  def process_ruby_repos
    @client.search_repositories('language:ruby').items.each do |repo|
      yield repo[:full_name]
    end
    true
  end

  def get_gemfile(full_repo_name)
    result = @client.contents(full_repo_name,path: 'Gemfile')[:content]
    Base64.decode64 result
  rescue Octokit::NotFound
    return ''
  end

  def get_gem_dependencies(full_repo_name)
    gemfile = get_gemfile(full_repo_name)
    gemfile.scan /gem\s*['|"]([^'"]+)['|"]/
  end

end