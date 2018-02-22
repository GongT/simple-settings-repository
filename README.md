# simple setting repository

### a `Too Young, Too Simple` IDEA config file sync.

Just backup and restore config files ( with some ignore ).

No any export/import actions. Extreme stable.

But you must quit IDE before restore any settings.

Do not support cross different OS.

Do not have any AUTO merge action like official settingRepository plugin.

## Usage
1. clone this repo to any-where
1. run `./install.sh`
1. type or select IDEA config file location
1. type your storage git repo (normally empty github repo's clone url)
1. when finish
1. run `./backup.sh` to backup, `./restore.sh` to restore.

clone multiple times to sync more than one config folder.
