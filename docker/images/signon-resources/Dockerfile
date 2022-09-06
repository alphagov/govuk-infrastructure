ARG base_image=ruby:2.7.5-slim
FROM ${base_image}
# TODO: use https://github.com/alphagov/govuk-ruby-images and stop running apt-get update here.
RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y build-essential && apt-get clean

ENV INFRA_HOME /src
RUN mkdir $INFRA_HOME

WORKDIR $INFRA_HOME
COPY Gemfile* $INFRA_HOME/
COPY .ruby-version $INFRA_HOME/
RUN bundle install --jobs 4
COPY lib $INFRA_HOME/lib
COPY Rakefile $INFRA_HOME/

CMD /bin/bash
