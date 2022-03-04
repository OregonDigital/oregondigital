#!/bin/bash

build_no="$1"
build_args="--compress -f docker/Dockerfile-prod"

if [ -z "$build_no" ]; then
   echo "Usage: $0 <build number>"
   exit 1
fi
tag1="registry.library.oregonstate.edu/od1-ruby:od1-${build_no}"

echo "Building for tag $tag1"
docker build ${build_args} . -t "$tag1"

echo "Logging into BCR as admin"
echo admin | docker login --password-stdin registry.library.oregonstate.edu

echo "pushing: $tag1"
docker push "$tag1"
echo $build_no > .version
