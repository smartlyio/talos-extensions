set -euo pipefail
TALOS_VERSION=v1.9.1
ARCH=amd64
PROFILE=installer
COUNTERCEPT_IMAGE=dev.artifactor.ee/talos-countercept-extension:wip

make countercept PLATFORM=linux/amd64
docker tag ghcr.io/siderolabs/countercept:wip "$COUNTERCEPT_IMAGE"
docker push "$COUNTERCEPT_IMAGE"

docker run --rm -t -v "$HOME/.docker/config.json:/docker-config/config.json" -e DOCKER_CONFIG="/docker-config" -v /dev:/dev --privileged -v "$PWD/_out:/out" "ghcr.io/siderolabs/imager:${TALOS_VERSION}" --arch "${ARCH}" \
  --system-extension-image ${COUNTERCEPT_IMAGE} --system-extension-image "ghcr.io/siderolabs/glibc:2.40"  ${PROFILE}
docker load -i ./_out/installer-${ARCH}.tar 
docker tag ghcr.io/siderolabs/installer:${TALOS_VERSION} dev.artifactor.ee/talos-countercept-installer:${TALOS_VERSION}
docker push dev.artifactor.ee/talos-countercept-installer:${TALOS_VERSION}
