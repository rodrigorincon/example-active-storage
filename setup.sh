#!/bin/sh

echo "if it running, stop project..."
docker-compose down

echo "removing old gemfile.lock..."
rm Gemfile.lock -f

echo "building project..."
docker-compose build

echo "create database..."
docker-compose run example_storage_app /bin/sh -c "bundle exec rake db:create"
docker-compose run example_storage_app /bin/sh -c "bundle exec rails db:migrate"
docker-compose run example_storage_app /bin/sh -c "bundle exec rails db:migrate RAILS_ENV=test"
docker-compose run example_storage_app /bin/sh -c "bundle exec rails db:seed"
