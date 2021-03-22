FROM ruby:2.5.0-alpine

WORKDIR /app

COPY . .

RUN bundle

ENTRYPOINT [ "bundle", "exec", "ruby", "run.rb" ]
