# SET THE FOLLOWING VARIABLES
# docker hub username
USERNAME=ppouliot
# image name
IMAGE=puppet-ipam

# Ensure the repo is up to date
git pull

# Bump Version
docker run --rm -v "$PWD":/app treeder/bump patch
VERSION=`cat VERSION`
set -x
echo "version: $VERSION"
# Bump Version in metadata.json
sed -i '' 's/^.*\"version\"\:.*/\"version\"\:\ \"'"$VERSION"'\",/' metadata.json

# run build

./build.sh -d
# tag it
git add -A
git commit -m "version $VERSION"
git tag -a "$VERSION" -m "version $VERSION"
git push
git push --tags
docker tag $USERNAME/$IMAGE:latest \
$USERNAME/$IMAGE:$VERSION \
$USERNAME/$IMAGE-ubuntu \
$USERNAME/$IMAGE-ubuntu:$VERSION 

# push it
docker tag $USERNAME/$IMAGE:latest $USERNAME/$IMAGE:$version
# docker push $USERNAME/$IMAGE-centos:latest $USERNAME:$IMAGE-centos:$VERSION
# docker push $USERNAME/$IMAGE-debian:latest $USERNAME:$IMAGE-debian:$VERSION
docker push $USERNAME/$IMAGE-ubuntu:latest $USERNAME:$IMAGE-ubuntu:$VERSION
