# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed.
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

Option.create([
  {:option_name=>'blog_title', :option_value=>'My Awesome Blog'},
  {:option_name=>'public_directory', :option_value=>'public'},
  {:option_name=>'admin_user', :option_value=>'admin'},
  {:option_name=>'admin_pass', :option_value=>rand(2**256).to_s(36)[0..15]}
])