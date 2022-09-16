#!/bin/bash

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

# core changes
go mod edit -require github.com/jpkrohling/collector-workspaces/pdata@${version}
go mod edit -require github.com/jpkrohling/collector-workspaces/semconv@${version}

# otelcorecol
module="cmd/otelcorecol"
pushd ${module}
go mod edit -require github.com/jpkrohling/collector-workspaces@${version}
popd

tag="${version}"
git commit -sam "Release script - updated all go.mod files"
git tag ${tag}
git push git@github.com:jpkrohling/collector-workspaces.git ${tag}
echo Core released

# tag them all
for module in cmd/builder cmd/otelcorecol internal/tools semconv pdata; do
    pushd ${module}
    tag="${module}/${version}"
    git tag ${tag}
    git push git@github.com:jpkrohling/collector-workspaces.git ${tag}
    popd
    echo ${module} released
done
