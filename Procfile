web: bundle exec puma -C config/puma.rb
release: bundle install && rails db:migrate RAILS_ENV=production && rails db:seed RAILS_ENV=production