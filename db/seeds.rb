# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed.
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

Option.create([
  {:option_name=>'blog_title', :option_value=>'A Lennon Blog', :option_type=>'string'},
  {:option_name=>'blog_tagline', :option_value=>'Another awesome, Lennon powered, blog.', :option_type=>'string'},
  {:option_name=>'blog_url', :option_value=>'http://localhost:9393', :option_type=>'string'},
  {:option_name=>'public_directory', :option_value=>'public', :option_type=>'string'},
  {:option_name=>'admin_user', :option_value=>'admin', :option_type=>'string'},
  {:option_name=>'admin_pass', :option_value=>(rand(2**256).to_s(36)[0..15]), :option_type=>'string'},
  {:option_name=>'date_format', :option_value=>'%b %d, %Y', :option_type=>'string'},
  {:option_name=>'posts_per_page', :option_value=>4, :option_type=>'integer'},
  {:option_name=>'auto_approve_comments', :option_value=>true, :option_type=>'boolean'},
  {:option_name=>'theme_name', :option_value=>'default', :option_type=>'string'},
])