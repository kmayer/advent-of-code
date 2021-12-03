#!/bin/sh -e

# By specifying the replacement string, "-I{}" but not mentioning it, all output from fswatch is swallowed
# Sometimes the rspec process will get disconnected from the parent process and run "forever"
# Setting the ulimit will stop the process. Unfortunately, silently
fswatch --one-per-batch --recursive --follow-links --latency=0.250 ./spec | (ulimit -t 60; xargs -n1 -I{} bundle exec rspec $*)
