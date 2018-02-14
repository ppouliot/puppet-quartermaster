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

./build.sh
# tag it
git add -A
git commit -m "version $VERSION"
git tag -a "$VERSION" -m "version $VERSION"
git push
git push --tags
docker tag \
$USERNAME/$IMAGE \
$USERNAME/$IMAGE:$VERSION \
$USERNAME/$IMAGE-centos \
$USERNAME/$IMAGE-centos:$VERSION \
#$USERNAME/$IMAGE-debian \
#$USERNAME/$IMAGE-debian:$VERSION \
$USERNAME/$IMAGE-ubuntu \
$USERNAME/$IMAGE-ubuntu:$VERSION 

# push it
docker push $USERNAME/$IMAGE:latest
docker push $USERNAME/$IMAGE-centos:latest
#docker push $USERNAME/$IMAGE-debian:latest
docker push $USERNAME/$IMAGE-ubuntu:latest
