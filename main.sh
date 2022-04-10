#!/bin/bash

exist_all_label=$(cat $CI_INFO_TEMP_DIR/labels.txt | grep "$ALL_LABEL" 2>&1 > /dev/null; echo $?)
exist_develop_label=$(cat $CI_INFO_TEMP_DIR/labels.txt | grep "$DEV_LABEL" 2>&1 > /dev/null; echo $?)
exist_staging_label=$(cat $CI_INFO_TEMP_DIR/labels.txt | grep "$STG_LABEL" 2>&1 > /dev/null; echo $?)
exist_production_label=$(cat $CI_INFO_TEMP_DIR/labels.txt | grep "$PROD_LABEL" 2>&1 > /dev/null; echo $?)

if [ $exist_all_label = "0" ]; then
  echo "Deploy all environment"
  list=$(jq -c '.develop + .staging + .production' ${DEPLOY_TARGET_FILE})
  echo "::set-output name=value::${list}"
elif [ $exist_develop_label = "0" -a $exist_staging_label = "0" -a $exist_production_label = "0" ]; then
  echo "Deploy all environment"
  list=$(jq -c '.develop + .staging + .production' ${DEPLOY_TARGET_FILE})
  echo "::set-output name=value::${list}"
elif [ $exist_develop_label = "0" -a $exist_staging_label = "0" ]; then
  echo "Deploy dev & stg"
  list=$(jq -c '.develop + .staging' ${DEPLOY_TARGET_FILE})
  echo "::set-output name=value::${list}"
elif [ $exist_develop_label = "0" -a $exist_production_label = "0" ]; then
  echo "Deploy dev & prod"
  list=$(jq -c '.develop + .production' ${DEPLOY_TARGET_FILE})
  echo "::set-output name=value::${list}"
elif [ $exist_staging_label = "0" -a $exist_production_label = "0" ]; then
  echo "Deploy stg & prod"
  list=$(jq -c '.staging + .production' ${DEPLOY_TARGET_FILE})
  echo "::set-output name=value::${list}"
elif [ $exist_develop_label = "0" ]; then
  echo "Deploy dev"
  list=$(jq -c '.develop' ${DEPLOY_TARGET_FILE})
  echo "::set-output name=value::${list}"
elif [ $exist_staging_label = "0" ]; then
  echo "Deploy stg"
  list=$(jq -c '.staging' ${DEPLOY_TARGET_FILE})
  echo "::set-output name=value::${list}"
elif [ $exist_production_label = "0" ]; then
  echo "Deploy prod"
  list=$(jq -c '.production' ${DEPLOY_TARGET_FILE})
  echo "::set-output name=value::${list}"
else
  export PR_NUMBER=$(echo ${PR_NUMBER})
  export DEPLOY_TARGET_FILE=$(echo ${DEPLOY_TARGET_FILE})
  github-comment post -org ${GITHUB_REPOSITORY%/*} -repo ${GITHUB_REPOSITORY#*/} --config ${GITHUB_ACTION_PATH}/.github-comment.yml -pr ${PR_NUMBER} -k select-label -var DEPLOY_TARGET_FILE:${DEPLOY_TARGET_FILE}
  exit 1
fi
echo "OUTPUT: $list"
