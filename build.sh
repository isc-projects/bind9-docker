#!/bin/sh

set -e

build() (
    set -e
    repository="$1"
    dir="$2"

    cd "$dir"

    TAGS=""
    while read -r tag; do
	TAGS="$TAGS -t $repository:$tag"
    done < tags
    # shellcheck disable=SC2086
    docker build --pull $TAGS .
    while read -r tag; do
	docker push "$repository:$tag"
    done < tags
)

repository=$(cat repository)

for dir in bind-esv bind bind-dev; do
    build "$repository" "$dir"
done
