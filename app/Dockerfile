FROM ruby:3.2.2

WORKDIR /app
COPY Gemfile ./
COPY Gemfile.lock ./
RUN bundle check || bundle install
