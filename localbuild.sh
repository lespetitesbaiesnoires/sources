#!/bin/bash

set -e
set -x 

rm -rf _site

SITE_BASEURL=""
SITE_URL="http://localhost:4000"

rm -rf _config.yml
cp -f _config_tpl.yml _config.yml

rm -rf index.html
cp fr/index.html index.html

sed -i 's@^\(baseurl:[[:space:]]*"\)[^#]*\("\)@\1'${SITE_BASEURL}'\2@' _config.yml 
sed -i 's@^\(url:[[:space:]]*"\)[^#]*\("\)@\1'${SITE_URL}'\2@' _config.yml 

cp fr/index.html index.html

bundle exec jekyll build
bundle exec htmlproofer _site --disable-external
bundle exec jekyll serve
