FROM ruby:2.5.0-alpine

WORKDIR /app

COPY . .

RUN apk update && apk add --no-cache \
  build-base \
  sqlite-dev

RUN bundle

ENTRYPOINT [ "bundle", "exec", "ruby", "run.rb" ]
