#!/usr/bin/env bash

each_running () {
	local ITEM_CALLBACK="$1"
	if [ -z "${ITEM_CALLBACK}" ]; then
		die "each_running() call error: no argument."
	fi
	local FOUND_CALLBACK="$2"
	local RUNNING_LIST=$(ps x | grep '[i]dea.paths.selector=')
	RET=$?
	if [ ${RET} -eq 0 ] ; then # found
		if [ -n "${FOUND_CALLBACK}" ]; then
			${FOUND_CALLBACK} ${RET}
		fi
		
		local NAME_LIST=( $( echo "${RUNNING_LIST}" | grep -oE "idea.paths.selector=\S+" | sed 's/idea.paths.selector=//' ) )
		local VMP_FILE_LIST=( $( echo "${RUNNING_LIST}" | grep -oE "jb.vmOptionsFile=\S+" | sed 's/jb.vmOptionsFile=//' ) )
		
		local i
		for i in $(seq 1 "${#NAME_LIST[@]}") ; do
			local VMP_FILE="${VMP_FILE_LIST[$((i -1))]}"
			local BIN_ROOT=$(dirname ${VMP_FILE})
			local INSTALL_ROOT=$(dirname ${BIN_ROOT})
			
			local CONFIG_FILE=$(
				eval $(
					echo "idea_home_path='${INSTALL_ROOT}'"
					cat "${BIN_ROOT}/idea.properties" | grep -v '^#' | sed 's/\./_/g'
				)
				echo ${idea_config_path}
			)
			
			${ITEM_CALLBACK} "$i" "${NAME_LIST[$((i -1))]}" "${INSTALL_ROOT}" "${CONFIG_FILE}"
		done
	fi
	
	return ${RET}
}
