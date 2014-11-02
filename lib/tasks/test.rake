namespace :test do
  namespace :neo4j do

    desc 'reset and start neo4j test instance'
    task :setup do
      Rake::Task['neo4j:reset_yes_i_am_sure'].invoke('test')
      Rake::Task['neo4j:start'].invoke('test')
    end

  end
end

task :test => 'test:neo4j:setup'