#!/bin/bash

# Import system info
. `dirname $PWD`/config/system.cfg

# Set Log
log_it="> /dev/null 2>$install_dir/logs/sanickiosk_update.log"
