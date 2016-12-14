#!/usr/bin/env bash

#!/usr/bin/env bash

if [[ $# == 0 ]]; then
    echo "Usage: $0 -d debug_level"
    exit 1
fi

while getopts d: argument
do
    case $argument in
        d) debug_level=$OPTARG
            ;;
        \?) echo "Usage: $0 -d debug_level"
            exit 1
            ;;
    esac
done
