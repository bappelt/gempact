namespace :test do
  namespace :neo4j do

    desc 'setup test instance'
    task :setup do
      Rake::Task['neo4j:install'].invoke('community-2.1.3','test')
      Rake::Task['neo4j:config'].invoke('test','7777')
      Rake::Task['neo4j:start'].invoke('test')
    end

    desc 'reset neo4j test instance'
    task :reset do
      Rake::Task['neo4j:reset_yes_i_am_sure'].invoke('test')
      Rake::Task['neo4j:start'].invoke('test')
    end

  end
end

task :test => 'test:neo4j:reset'