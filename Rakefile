namespace :db do
  task :environment do
    require 'active_record'
    ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :dbfile =>  'db/development.sqlite3'
  end

  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
  
  desc 'Load the seed data from db/seeds.rb'
  task :seed => :environment do
    require 'blog'
    seed_file = File.join('.', 'db', 'seeds.rb')
    load(seed_file) if File.exist?(seed_file)
  end
  
end
