#!/usr/bin/env bash

die () {
	echo -e "\e[38;5;9m$*\e[0m" >&2
	exit 1
}

OLD_PWD="$(pwd)"
cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
if [ "${OLD_PWD}" = "$(pwd)" ]; then
	MAYBE="can be"
else
	MAYBE="MUST be"
fi

if [ -h config ] || [ -e config ] ; then
	die "config folder is exists, unlink it if you want change location."
fi
if [ -h repo ] || [ -e repo ] ; then
	die "repo folder is exists, remove it if you want change remote."
fi

RUNNING_MSG=
found () {
	RUNNING_MSG='OR you can use number to quick select path.'
	echo ""
	echo " There are some IDEA running: "
	echo ""
}

CONFIG_LIST=()
every_idea () {
	local i=$1
	local NAME=$2
	local INSTALL_ROOT=$3
	local CONFIG_FILE=$4
	CONFIG_LIST[$i]="${CONFIG_FILE}"
	echo -e "  * \e[38;5;14m[$i]\e[0;2m ${NAME} - \e[0m${CONFIG_FILE}"
}

source ./lib/process.sh
each_running every_idea found
if [ $? -eq 0 ]; then
	echo ""
fi

echo "Where your idea config file ($MAYBE absolute path)? ${RUNNING_MSG}"
read -p '> ' IDEA_CONFIG_PATH

if echo "$IDEA_CONFIG_PATH" | grep -qE "^[0-9]+$" &>/dev/null ; then # is a number, and gt 0
	if [ -z "${CONFIG_LIST[$IDEA_CONFIG_PATH]}" ]; then
		die "no this selection."
	fi
	IDEA_CONFIG_PATH="${CONFIG_LIST[$IDEA_CONFIG_PATH]}"
	
	if [ ! -d "${IDEA_CONFIG_PATH}/" ]; then
		mkdir -p "${IDEA_CONFIG_PATH}/"
	fi
fi

if [ -d "${IDEA_CONFIG_PATH}/config/" ]; then
	IDEA_CONFIG_PATH="${IDEA_CONFIG_PATH}/config/"
elif [ -d "${IDEA_CONFIG_PATH}/" ]; then
	echo -n
else
	die "cannot find config in folder: ${IDEA_CONFIG_PATH}"
fi

realpath "$IDEA_CONFIG_PATH" >/dev/null || die "config folder not exists: $IDEA_CONFIG_PATH"
IDEA_CONFIG_PATH="$(realpath "$IDEA_CONFIG_PATH")"

echo ""

echo "Where is your remote git storage url?"
read -p '> ' REMOTE_GIT_URL

echo ""
echo -e "\e[38;5;11mlocal:\e[0m\t${IDEA_CONFIG_PATH}"
echo -e "\e[38;5;11mremote:\e[0m\t${REMOTE_GIT_URL}"
echo ""
read -p "press Enter to continue."

echo ""

git clone ${REMOTE_GIT_URL} ./repo || die "cannot clone remote. (command: git clone '${REMOTE_GIT_URL}' ./repo )"
ln -s "${IDEA_CONFIG_PATH}" ./config || die "cannot create link. (command: ln -s '${IDEA_CONFIG_PATH}' ./config )"

if [ -e "./repo/.gitignore" ]; then
	IGNORE_DATA="$(< "./repo/.gitignore")"
	push_ignore () {
		local LINE="$1"
		if echo "${IGNORE_DATA}" | grep -q -E "^$LINE$" ; then
			return
		fi
		echo "$LINE" >> "./repo/.gitignore"
	}
else
	push_ignore () {
		local LINE="$1"
		echo "$LINE" >> "./repo/.gitignore"
	}
fi

push_ignore 'settingsRepository/'
push_ignore 'tasks/'

push_ignore 'port.lock'
push_ignore 'port'
push_ignore 'phpstorm.key'

push_ignore 'options/recentProjectDirectories.xml*'
push_ignore 'options/window.manager.xml'
push_ignore 'options/window.state.xml'
push_ignore 'options/statistics.*.xml'
push_ignore 'options/*.statistics.xml'
push_ignore 'options/dimensions.xml'
push_ignore 'options/options.xml'

push_ignore 'javascript/nodejs/'
push_ignore '*.jar'

echo ""
echo "Complete!"
