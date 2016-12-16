#!/usr/bin/env bash

echo $@
echo $*
echo "$@"
echo "$*"
echo "------------------------------"

# 以下2段代码输出结果一致
for var in $@; do
    echo ${var}
done
echo "------------------------------"

for var in $*; do
    echo ${var}
done
echo "------------------------------"


# 以下2段代码输出结果不一致
for var in "$@"; do
    echo ${var}
done
echo "------------------------------"

for var in "$*"; do
    echo ${var}
done
echo "------------------------------"

