#!/usr/bin/env bash
#
# This pipe is an example to show how easy it is to create pipes for Bitbucket Pipelines.
#
# Required globals:
#   AWS_ACCESS_KEY_ID
#   AWS_SECRET_ACCESS_KEY
#   EKS_CLUSTER
#   VERSION
#   ENVIRONMENT (default: 'dev')
#   AWS_REGION (default: 'us-east-1')
#   PROJECT
#   BUILD_HELM=${BUILD_HELM:="no"}
#   NAMESPACE=${ENVIRONMENT:="default"}
#   HELM_URL
#
# Optional globals:
#   DEBUG (default: 'false')
#   APP_CONFIG

source "$(dirname "$0")/common.sh"

# if we are deploying with a tag it should have a version.txt instead of someone manually passing it in"
if [[ -f "${BITBUCKET_CLONE_DIR}/version.txt" ]]; then
  VERSION=$(cat version.txt)
fi

# Required parameters
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?'AWS_ACCESS_KEY_ID variable missing.'}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?'AWS_SECRET_ACCESS_KEY variable missing.'}
EKS_CLUSTER=${EKS_CLUSTER:?'EKS_CLUSTER variable missing.'}
VERSION=${VERSION:?'VERSION variable missing.'}
PROJECT=${PROJECT:?'PROJECT variable missing.'}
HELM_URL=${HELM_URL:?'HELM_URL variable missing.'}

# Default parameters
ENVIRONMENT=${ENVIRONMENT:="dev"}
NAMESPACE=${NAMESPACE:="default"}
AWS_REGION=${AWS_REGION:="us-east-1"}
DEBUG=${DEBUG:="false"}
BUILD_HELM=${BUILD_HELM:="no"}

makedir="$(dirname "$0")"

info "Deploying Version ${VERSION} of ${PROJECT} to ${ENVIRONMENT} on Bitbucket Env $BITBUCKET_DEPLOYMENT_ENVIRONMENT to k8s namespace ${NAMESPACE}"

info "Executing the pipe..."

info "Grabbing kubeconfig from the cluster"
run aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER
if [[ "${status}" == "0" ]]; then
  success "Success!"
else
  fail "Error!"
fi

if [[ -n ${APP_CONFIG} ]]; then
  info "Loading Application Proptery file ${APP_CONFIG} into config map"
  kubectl delete configmap ${PROJECT}-prop -n ${NAMESPACE} || true
  kubectl create configmap ${PROJECT}-prop --from-file ${BITBUCKET_CLONE_DIR}/${APP_CONFIG} -n ${NAMESPACE}
fi

info "Executing helm chart for ${PROJECT} for Environment ${ENVIRONMENT}"

if [[ ${BUILD_HELM} == 'yes' ]]; then
    info "Tagging Version in Helm Chart"
    run make -C $makedir tag
   if [[ "${status}" == "0" ]]; then
      success "Success!"
    else
      fail "Error!"
    fi   

    info "Building Helm Chart"
    run make -C $makedir build
    if [[ "${status}" == "0" ]]; then
      success "Success!"
    else
      fail "Error!"
    fi

    info "Pushing Helm Chart to Artifactory"
    run make -C $makedir release
    if [[ "${status}" == "0" ]]; then
      success "Success!"
    else
      fail "Error!"
    fi
fi

info "Deploying Helm Chart to Environment ${ENVIRONMENT} on k8s namespace ${NAMESPACE}"
run make -C $makedir upgrade${ENVIRONMENT}
if [[ "${status}" == "0" ]]; then
  success "Success!"
else
  fail "Error!"
fi

if [[  -z $SKIP_ROLLOUT_STATUS ]]; then
  info "Checking deployment status"
  run kubectl  rollout status -w deployments/${PROJECT} -n ${NAMESPACE}
  if [[ "${status}" == "0" ]]; then
    success "Success!"
  else
    fail "Error!"
  fi 
fi