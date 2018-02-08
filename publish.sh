#!/bin/bash

set -e

function publish() {
	if [[ -n "$(git status --porcelain)" ]]; then
		echo "Working tree *NOT* clean."
		exit 1
	fi

	current_branch="$(git symbolic-ref --short -q HEAD)"
	current_branch=${current_branch:-master}

	site="_site"
	cname="mamreoak.cc"
	tmp_branch="tmp"

	git fetch --prune
	git checkout -B $tmp_branch

	bundle exec jekyll build

	cat > $site/CNAME <<- EOF
	$cname
	EOF

	git add -f $site
	git commit -m "chore(release): generate site"
	if [[ -n "$(git rev-parse --verify --quiet gh-pages)" ]]; then
		git branch -D gh-pages
	fi
	git subtree split --prefix=$site -b gh-pages
	git push -f origin gh-pages:gh-pages
	git checkout $current_branch
	git branch -D gh-pages $tmp_branch
}

publish
