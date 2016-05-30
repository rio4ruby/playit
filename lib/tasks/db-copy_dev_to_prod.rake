# encoding: utf-8

namespace :db do
  desc "Copy development database to production"
  task :copy_dev_to_prod, [:topdir, :needs] => [:environment] do |t,args|
    sh %{pg_dump -h db.kitatdot.net -U play play_development > play.sql} do |ok, res|
      if ok
        puts "pg_dump successful #{res}"
        sh %{dropdb -h db.kitatdot.net -U play play_production}
        sh %{createdb -h db.kitatdot.net -U play -O play play_production}
        sh %{psql -h db.kitatdot.net -U play play_production < play.sql} do |ok2, res2|
          if ok2
            puts "load to production succesful #{res2}"
          end
        end
      end
    end
    # sh 
    # sh 
  end
end
