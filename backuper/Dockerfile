FROM ruby:2.6.0-alpine

RUN apk update && apk add --no-cache \
  bash \
  tzdata \
  && rm -fr /tmp/* /var/cache/apk/*

WORKDIR /app

COPY Gemfile* ./

RUN bundle

COPY run.rb ./
