FROM ubuntu:14.04
MAINTAINER https://github.com/cloudfoundry/pipelines_og

RUN \
      apt-get update && \
      apt-get -qqy install --fix-missing \
            build-essential \
            curl \
            libcurl4-openssl-dev \
            git \
            libreadline6 \
            libreadline6-dev \
            wget \
            runit \
            openssl \
            unzip \
            zip \
      && \
      apt-get clean

# Install go
RUN wget https://storage.googleapis.com/golang/go1.7.1.linux-amd64.tar.gz && \
  tar -C /usr/local -xzf go1.7.1.linux-amd64.tar.gz && \
  rm -rf go1.7.1.linux-amd64.tar.gz

# Create directory for GOPATH
RUN mkdir -p /go/bin

# set GOPATH
ENV GOPATH /go

# add go and GOPATH/bin to PATH
ENV PATH $PATH:$GOPATH/bin:/usr/local/go/bin

# Install ruby-install
RUN curl https://codeload.github.com/postmodern/ruby-install/tar.gz/v0.5.0 | tar xvz -C /tmp/ && \
          cd /tmp/ruby-install-0.5.0 && \
          make install

# Install Ruby
RUN ruby-install ruby 2.3.1 -- --disable-install-rdoc

# Add ruby to PATH
ENV PATH $PATH:/home/root/.gem/ruby/2.3.1/bin:/opt/rubies/ruby-2.3.1/lib/ruby/gems/2.3.0/bin:/opt/rubies/ruby-2.3.1/bin

# Set permissions on ruby directory
RUN chmod -R 777 /opt/rubies/

# Install bundler
RUN /opt/rubies/ruby-2.3.1/bin/gem install bundler -v '1.12.4' --no-rdoc --no-ri

# Install bosh_cli
#RUN /opt/rubies/ruby-2.3.1/bin/gem install bosh_cli --no-rdoc --no-ri
RUN wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.28-linux-amd64 && \
  mv bosh-cli-* /usr/local/bin/bosh && \
  chmod +x /usr/local/bin/bosh


# Install jq as a nice to have on container debugging
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \
  mv jq-linux64 /usr/local/bin/jq && \
  chmod +x /usr/local/bin/jq

# Install spiff
RUN wget https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_linux_amd64 && \
  mv spiff_linux_amd64 /usr/local/bin/spiff && \
  chmod +x /usr/local/bin/spiff
