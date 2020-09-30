#========================================================================================
# This Dockerfile creates a container image with the dependencies required
# to deploy
# This is needed for running the deploy scripts in a container environment like Concourse.
#========================================================================================
FROM governmentpaas/awscli:latest

RUN apk add --no-cache ruby-full=2.7.1-r3

# Move Gemfile and ruby version into
COPY scripts scripts

WORKDIR /scripts/

RUN gem install bundler --version 2.1.4

RUN bundle install

ENTRYPOINT ["/bin/ash"]
