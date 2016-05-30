# encoding: UTF-8
BEGIN {
  Encoding.default_internal = "UTF-8"
  Encoding.default_external = "UTF-8"
}

def pg_args(db_config)
  "-U #{db_config['username']} -h #{db_config['host']} #{db_config['database']}"
end
def dump_table_cmd(table)
  db_config = Rails.application.config.database_configuration[Rails.env]
  "pg_dump #{pg_args(db_config)} -t #{table} -a > data/#{table}.sql"
end
def load_table_cmd(table)
  db_config = Rails.application.config.database_configuration[Rails.env]
  "psql #{pg_args(db_config)} < data/#{table}.sql"
end
namespace :db do

  desc 'Load the seed data from db/seeds.rb (customized to not check pending migrations)'
  task :seednocheck => :environment do
    # db_namespace['abort_if_pending_migrations'].invoke
    Rails.application.load_seed
  end

  desc 'This task dumps your database config to the console'
  task :dumpconfig => :environment do
    db_config = Rails.application.config.database_configuration[Rails.env]
    puts pg_args(db_config)
  end

  
  desc "Dump db tables to data directory"
  task :dumptables => [:environment] do |t,args|
    tables = %w[artists file_dirs albums songs genres tags audio_files audio_files_tags image_files lyrics]
    tables.each do |table|
      cmd = dump_table_cmd(table)
      sh cmd
    end
  end
end
