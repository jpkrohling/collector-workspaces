#!/bin/bash

while getopts v: flag
do
    case "${flag}" in
        v) version=${OPTARG};;
    esac
done

if [[ -z $version ]]; then
    echo "Version is empty, specify one with -v. Ex.: $0 -v v0.0.1"
    exit 1
fi

# leaf modules
for module in cmd/builder internal/tools semconv pdata; do
    pushd ${module}
    tag="${module}/${version}"
    git tag ${tag}
    git push git@github.com:jpkrohling/collector-workspaces.git ${tag}
    popd
    echo ${module} released
done

# core, which depends on some of the above
tag="${version}"

# bump the dependencies we just released
go mod edit -require github.com/jpkrohling/collector-workspaces/pdata@${version}
go mod edit -require github.com/jpkrohling/collector-workspaces/semconv@${version}

go mod tidy
git commit -sam "Release script - updated core go.mod"

git tag ${tag}
git push git@github.com:jpkrohling/collector-workspaces.git ${tag}
echo Core released

# otelcorecol, which depends on the core
module="cmd/otelcorecol"
pushd ${module}
tag="${module}/${version}"

go mod edit -require github.com/jpkrohling/collector-workspaces@${version}

go mod tidy
git commit -sam "Release script - updated otelcorecol go.mod"

git tag ${tag}
git push git@github.com:jpkrohling/collector-workspaces.git ${tag}
popd
echo ${module} released
