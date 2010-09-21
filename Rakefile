namespace :db do
  task :environment do
    require 'active_record'
    ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database =>  'db/development.sqlite3'
  end

  desc "Migrate the database"
  task(:migrate => :environment) do
    require 'logger' 
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
  
  desc 'Load the seed data from db/seeds.rb'
  task :seed => :environment do
    require 'lib/option'
    seed_file = File.join('.', 'db', 'seeds.rb')
    load(seed_file) if File.exist?(seed_file)
    puts '===================================================='
    puts "You've Successfully Loaded your blog's initial data."
    puts '----------------------------------------------------'
    puts "Your Admin username is: admin"
    puts "Your Admin password is: #{Option.find_by_option_name('admin_pass')['option_value']}"
    puts '===================================================='
  end
  
end
