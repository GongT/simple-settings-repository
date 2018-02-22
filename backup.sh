#!/usr/bin/env bash

die () {
	echo -e "\e[38;5;9m$*\e[0m" >&2
	exit 1
}

cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

echo "config -> REPO"
rsync -aLq --progress ./config/. ./repo --exclude-from=./repo/.gitignore || die "cannot copy file from ./config to ./repo"

cd repo

git status
