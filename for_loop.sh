#!/usr/bin/env bash

for candidate in x y z; do
    echo ${candidate}
done
echo "-----------------------"


for candidate in x \
                y \
                z; do
    echo ${candidate}
done
echo "-----------------------"


