FROM ruby:3.1.4

RUN apt-get update -qq && apt-get install -y build-essential cron

ENV APP_DIR=/app

RUN mkdir -p $APP_DIR
WORKDIR $APP_DIR

# Cache bundle install
COPY Gemfile* ./

COPY . $APP_DIR
RUN bundle install

RUN crontab -l | { cat; echo ""; } | crontab -
RUN cron && bundle exec whenever --set 'environment=development' --update-crontab
