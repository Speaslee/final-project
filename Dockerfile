FROM heroku/jruby

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:kirillshkrogalev/ffmpeg-next && \
    apt-get update && \
    apt-get install -y ffmpeg &&\
    rm -rf /var/lib/apt/lists/*

RUN wget -O /opt/processing.tgz http://download.processing.org/processing-2.2.1-linux64.tgz
WORKDIR /opt
RUN tar xvf processing.tgz
RUN mv processing-2.2.1 processing &&\
  rm -rf /opt/processing/modes/java/libraries/minim

RUN wget -O /opt/minim.tar.gz https://github.com/ddf/Minim/archive/v2.2.0.tar.gz
WORKDIR /opt
RUN tar xvf minim.tar.gz
RUN mv Minim-2.2.0 /opt/processing/modes/java/libraries

RUN mkdir /app/frames

COPY . /app/user
WORKDIR /app/user
RUN gem install bundler
RUN bundle install
RUN mv /opt/processing /app/user
