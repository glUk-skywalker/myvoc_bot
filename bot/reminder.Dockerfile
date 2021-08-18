FROM ruby:2.5.0-alpine

RUN apk update && apk add --no-cache \
  build-base \
  sqlite-dev \
  tzdata \
  bash

RUN rm -fr /tmp/* /var/cache/apk/*

WORKDIR /app

COPY Gemfile* ./

RUN bundle

COPY . .
