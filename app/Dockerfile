FROM ruby:3.2.2

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "4567"]
