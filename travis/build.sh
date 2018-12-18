#!/bin/bash

set -x
set -e





function configure_git () {
	git config --global user.name "Travis CI"
	git config --global user.email sebastien@boyron.eu
}



function clone_repo () {
	rm -rf /tmp/build
	git clone --single-branch -b $BRANCH --depth 1 $REPO /tmp/build

}

function test_site () {
	rm -rf _site
	# build and test using right baseurl and url (to allow testing with htmlproofer)
	cp -f _config_tpl.yml _config.yml
	cp -f fr/index.html index.html
	bundle exec jekyll build
	bundle exec htmlproofer _site --disable-external
	rm _config.yml
	rm index.html

}

function build_site () {
	# Clean _site folder
	rm -rf _site
	mkdir -p /tmp/build/${SITE_BASEURL}
	ln -sf /tmp/build/${SITE_BASEURL} _site

	# Set default page to french language
	cp -f fr/index.html index.html

	# customize config reguarding the target (dev/prod)
	cp -f _config_tpl.yml _config.yml
	sed -i 's@^\(baseurl:[[:space:]]*"\)[^#]*\("\)@\1'${SITE_BASEURL}'\2@' _config.yml 
	sed -i 's@^\(url:[[:space:]]*"\)[^#]*\("\)@\1'${SITE_URL}'\2@' _config.yml 

	cat _config.yml
	
	# build site
	bundle exec jekyll build
	
	# Copy google file
	cp google*.html /tmp/build/${SITE_BASEURL}/
	echo "${CNAME}" > /tmp/build/CNAME
 
	# clean
	rm _config.yml
	rm index.html
}


function push () {
	pushd /tmp/build
	git status
	git diff
	git add --all
	git status
	git commit -m "Travis automatic build $TRAVIS_BUILD_NUMBER ($TRAVIS_COMMIT_MESSAGE)"
	git log
	git push $REPO $BRANCH
	popd
}





# skip if pull request 
if [ "$TRAVIS_PULL_REQUEST" == "true" ]; then
  echo "Build triggered on pull request, aborting!"
  exit 0
fi

case "$TRAVIS_BRANCH" in
	"master")
		REPO="https://${GITHUB_OAUTH_TOKEN}@github.com/lespetitesbaiesnoires/lespetitesbaiesnoires.github.io.git"
		BRANCH="master"
		CNAME="www.lespetitesbaiesnoires.com"
		SITE_URL="https://${CNAME}"
		SITE_BASEURL=""
	;;
	"develop")
		REPO="https://${GITHUB_OAUTH_TOKEN}@github.com/lespetitesbaiesnoires/sources.git"
		BRANCH="gh-pages"
		CNAME="dev.lespetitesbaiesnoires.com"
		SITE_URL="https://${CNAME}"
		SITE_BASEURL="/37beeb3424e4da159d53fc5b56c2b92b565812c3"
	;;
	*)
		echo "Nothing to do on build for branch/tag $TRAVIS_BRANCH"
		exit 0
	;;
esac
	


configure_git
test_site
clone_repo
build_site
push
