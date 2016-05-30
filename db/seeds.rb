# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def create_user(email,password,name="")
  user = User.find_by_email(email);
  user ||= User.create!(:email => email, :password => password, :password_confirmation => password, :name => name, :confirmed_at => Time.now.utc)
  user
end
def create_admin_user(email,password)
  user = AdminUser.find_by_email(email);
  user ||= AdminUser.create!(:email => email, :password => password, :password_confirmation => password)
  user
end
def pg_args(db_config)
  "-U #{db_config['username']} -h #{db_config['host']} #{db_config['database']}"
end
def load_table_cmd(table)
  db_config = Rails.application.config.database_configuration[Rails.env]
  "psql #{pg_args(db_config)} < data/#{table}.sql"
end

puts 'SETTING UP DEFAULT USER LOGIN'
user = create_user('admin@kitatdot.net','please',"First User")
puts 'First user created: ' << user.name
user.add_role :admin

shared_user = create_user('shared@kitatdot.net','please',"Shared User")
puts 'Shared user created: ' << shared_user.name

demo_user = create_user('demo@kitatdot.net','demodemo',"Demo User")
puts 'Demo user created: ' << demo_user.name

#admin_user = AdminUser.create!(:email => 'admin@example.com', :password => 'please', :password_confirmation => 'please')
admin_user = create_admin_user('admin@kitatdot.net','please')
puts 'New Admin user created: ' << admin_user.email

tables = %w{artists file_dirs image_files albums songs genres tags audio_files audio_files_tags lyrics}
tables.each do |table|
  puts "Populate #{table}"
  #system("psql -h db.kitatdot.net -U play playit_development < data/#{table}.sql")
  system(load_table_cmd(table))
end
