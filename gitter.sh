#!/bin/bash
# gitter by motty sisam


git_main() {
  local command
  local arg
  local branch
  local current_work_branch

  exec="gitter"
  command="$1"
  arg="$2"

  echo ${command}
  echo ${arg}

  if [[ "${command}" == "create-branch" ]]; then
    branch="${arg}"
    echo "creating branch ${branch}"
    git_create_branch "${branch}"
    current_work_branch="$(git rev-parse --abbrev-ref HEAD)"
    if [[ "${branch}" == "${current_work_branch}" ]]; then
      clear;
      echo "branch: ${branch} is ready"
    else
      echo "an error occur - not working branch?"
    fi

  elif [[ "${command}" == "update_master" ]]; then
    echo "updating master.."
    readonly current_work_branch="$(git rev-parse --abbrev-ref HEAD)"
    git_update_master
    if [[ "${current_work_branch}" =~ "master" ]]; then
      echo "staying on master"
    else
      git checkout "${current_work_branch}"
    fi

  elif  [[ -z "${command}" ]]; then
    echo "Syntax: $exec [command] [arg] " >&2
    echo "- $exec create-branch BRANCH_NAME" >&2
    echo "- $exec update-master" >&2
    echo "- $exec push-now" >&2
    echo "- $exec reset-fetch" >&2
    exit 0;
  fi

}

git_create_branch() {
  local branch
  branch="$1"
  status=$(git_check_status)
  if [[ "${status}" =~ "ok" ]] ; then
      echo "no changes awaiting, creating new branch: ${branch}"
      git_create_and_checkout_branch "${branch}"
  else
      echo "Please take care of changes: ${status}" >&1
      exit 0;
  fi

}

git_check_status() {
  local status
  local changes

  changes=$(git status --porcelain)

  if [[ -z $changes ]]; then
    status="ok"
  else
    status="not_ok"
  fi

  echo "${status}"
}

git_create_and_checkout_branch() {
  local branch
  branch="$1"

  git_update_master
  git checkout -b "${branch}"

}

git_update_master() {

  local master_work_branch
  git checkout master;

  master_work_branch="$(git rev-parse --abbrev-ref HEAD)"
    if [[ "${master_work_branch}" =~ "master" ]]; then
      git reset --hard contra/master;
      git push -f;
      git fetch contra;
      git rebase contra/master;
      git push -f;
    else
      echo "an error occur - not on master branch"
    fi

}


git_push_now() {

  git add .;
  git commit --amend -C HEAD;
  git push -f

}

git_reset_and_fetch() {

  git_reset
  git_fetch

}

git_fetch() {

  git fetch contra;
  git rebase contra/master;
  git push -f

}

git_reset() {

  git reset --hard contra/master;
  git push -f

}
