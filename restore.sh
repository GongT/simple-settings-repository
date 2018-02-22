#!/usr/bin/env bash

die () {
	echo -e "\e[38;5;9m$*\e[0m" >&2
	exit 1
}

cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

every_idea () {
	local CFG=${4%/}
	if [ "$CFG" = "$CONFIG_PATH" ]; then
		# die "Yor $2 is running, you must close it before restore settings."
		echo ""
	fi
}

CONFIG_PATH="$(readlink ./config)"
CONFIG_PATH=${CONFIG_PATH%/}

source ./lib/process.sh
each_running every_idea

echo "REPO -> config"
rsync -aLKv --progress ./repo/. ./config --exclude .git --exclude .gitignore || die "cannot copy file from ./repo to ./config"
