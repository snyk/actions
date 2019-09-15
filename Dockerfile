FROM ruby

WORKDIR /app

COPY build.rb .
COPY _templates _templates

CMD ruby build.rb

