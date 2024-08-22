#!/bin/sh
echo "Bundle check..."
bundle check || bundle install

echo "Migrating..."
bundle exec rails db:migrate

echo "Removing tmp folder..."
rm tmp/* -Rf

echo "Starting server..."
bundle exec rails s -b 0.0.0.0