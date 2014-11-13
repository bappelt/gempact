class GitHubClient

  def initialize
    @client = Octokit::Client.new(:access_token => ENV['GITHUB_TOKEN'])
  end

  def process_ruby_repos
    result = @client.all_repositories
    result.each do |repo|
      yield repo[:full_name]
    end
    last_response = @client.last_response
    while last_response.rels[:next]
      puts "getting #{last_response.rels[:next].href}"
      last_response = last_response.rels[:next].get
      last_response.data.each do |repo|
        yield repo[:full_name]
      end
    end
    true
  end


  def get_gemfile(full_repo_name)
    result = @client.contents(full_repo_name, path: 'Gemfile')[:content]
    Base64.decode64 result
  rescue Octokit::NotFound
    return ''
  end

  def get_gem_dependencies(full_repo_name)
    gemfile = get_gemfile(full_repo_name)
    gemfile.scan /gem\s*['|"]([^'"]+)['|"]/
  end

end