FROM ruby:2.1

MAINTAINER oqpvq <o+docker@qp.vc>
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y qt5-default libqt5webkit5-dev postgresql-client sqlite3 graphviz libxml2-dev libxslt-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/breunigs/keks.git .
RUN bundle install --deployment --without development
RUN echo "GIT_REVISION='$(git rev-parse HEAD)'" > config/initializers/git_revision.rb
RUN bundle exec rake assets:precompile


