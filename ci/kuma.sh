#!/usr/bin/env bash

KUMA_VERSION=1.2.2
CURRENT_VERSION=$((kumactl version) 2>&1 | awk '{print $2}')

echo "desired version: ${KUMA_VERSION}"
echo "current version: ${CURRENT_VERSION}"

if ! hash kumactl || [ "${CURRENT_VERSION}" != "${KUMA_VERSION}" ]; then
  tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
  echo "working dir: ${tmp_dir}"
  pushd $tmp_dir
  mkdir -p ~/.local/bin
  export PATH=${PATH}:~/.local/bin
  export VERSION=$KUMA_VERSION
  curl -L https://kuma.io/installer.sh | sh -
  mv kuma-${VERSION}/bin/* ~/.local/bin/
  popd
  rm -rf $tmp_dir
fi
