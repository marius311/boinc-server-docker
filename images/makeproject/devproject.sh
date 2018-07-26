#!/bin/bash

set -e

eval "$@"

if [ "$1" != "bash" ]; then
    makeproject-step1.sh
    makeproject-step2.sh
fi
