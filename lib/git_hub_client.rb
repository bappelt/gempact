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
    result = @client.search_code("Gemfile NOT lock in:path path:/ repo:#{full_repo_name}").items[0]
    return '' if result.nil?
    b64 = result.rels[:self].get.data[:content]
    Base64.decode64 b64
  end

  def get_gem_dependencies(full_repo_name)
    gemfile = get_gemfile(full_repo_name)
    gemfile.scan /gem\s*['|"]([^'"]+)['|"]/
  end

end