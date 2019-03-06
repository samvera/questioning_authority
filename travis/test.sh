#!/bin/bash

echo -e "\n\n\033[0;32mTravis test.sh script\033[0m"

echo -e "\n\n\033[1;33mMaking dependency cache directory\033[0m"
mkdir -p dep_cache
echo "Listing directory contents:"
ls -l dep_cache

echo -e "\n\n\033[1;33mInstalling Code Climate test reporting tool\033[0m"
if [ ! -f dep_cache/cc-test-reporter ]; then
  curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./dep_cache/cc-test-reporter
  chmod +x ./dep_cache/cc-test-reporter
fi
export PATH=$PATH:$(pwd)/dep_cache

echo -e "\n\n\033[1;33mRunning RSpec test suite with code coverage\033[0m"
cc-test-reporter before-build
# bundle exec rake qa:travis:rspec
RSPEC_EXIT_CODE=$?
cc-test-reporter after-build --exit-code $RSPEC_EXIT_CODE

exit $RSPEC_EXIT_CODE
