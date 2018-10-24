#!/bin/bash

set -e
set -x 

rm -rf _site
bundle exec jekyll build
bundle exec htmlproofer _site --disable-external
bundle exec jekyll serve
