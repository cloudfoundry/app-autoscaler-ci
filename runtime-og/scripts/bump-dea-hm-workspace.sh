#!/usr/bin/env bash
set -e -x

repo=$1
workspace_repo=$2

source ~/.bashrc

export TERM=xterm-256color
export GIT_PAGER=

pushd $repo
  MASTER_SHA=$(git rev-parse HEAD)
popd

pushd dea-hm-workspace
  pushd src/$workspace_repo
    git fetch
    git checkout $MASTER_SHA
  popd

  set +e
    git diff --exit-code
    exit_code=$?
  set -e

  if [[ $exit_code -eq 0 ]]
  then
    echo "There are no changes to commit."
  else
    git config user.name "RUNTIME OG CI"
    git config user.email "runtime_og+ci@us.ibm.com"

    git add src/$workspace_repo

    scripts/submodule-log
    scripts/submodule-log | git commit -F -
  fi
popd

git clone dea-hm-workspace bumped/dea-hm-workspace
