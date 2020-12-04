#!/bin/bash

# By specifying the replacement string, "-I{}" but not mentioning it, all output from fswatch is swallowed
fswatch --one-per-batch --recursive --follow-links --latency=0.250 . | xargs -n1 -I{} bundle exec rspec
