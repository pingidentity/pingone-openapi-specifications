#!/usr/bin/env bash

# We do this because of a bug in the generator where a field may be `oneOf` either a string type or a empty object type
sed 's/MapmapOfStringAny/Object/g' $1 > "$1.tmp" && mv "$1.tmp" $1

# Typical go formatting for consistency
gofmt -w -s $1
goimports -w $1