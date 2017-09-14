#!/bin/bash

set -e -x

source ~/.bashrc

echo "=====ENVIRONMENT====="
printenv

cd dea_next

gem install bundler -v '1.11.2' --no-rdoc --no-ri
bundle install

bundle exec rspec spec/unit
