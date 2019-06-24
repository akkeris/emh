FROM akkeris/rubychrome:2.6-lithium-1.2
RUN apt-get update
RUN apt-get install -y libkrb5-dev python python-pip
RUN pip install awscli
RUN bundle config --global frozen 1

WORKDIR /gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle config --delete frozen
RUN bundle install

ENV APP_DIR /app

WORKDIR /app
COPY . .

CMD ./start.sh

