# Bitbucket Pipelines Pipe: bitbucket-k8-helm-pipe

This pipe is used to build and deploy applicaitons via helm charts.

## YAML Definition

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
script:
  - pipe: docker://myspace/bitbucket-k8-helm-pipe:latest
    variables:
      #BUILD_HELM: '<string>' optional yes|no
      AWS_ACCESS_KEY_ID: '<string>'
      AWS_SECRET_ACCESS_KEY: '<string>'
      EKS_CLUSTER: '<striing>'
      VERSION: '<string>'
      PROJECT: '<string>'
      DOCKER_USER: '<string>'
      DOCKER_PASS: '<string>'
      CHART_REPO: '<string>'
      ENVIRONMENT: '<string>'
      AWS_REGION: '<string>'
      #DEBUG: '<string>' optional
      #APP_CONFIG: '<string>' optional
      NAMESPACE: '<string>' 
      HELM_URL: '<string>'
```
## Variables

| Variable              | Usage                                                                                       |
| ------------------------- | --------------------------------------------------------------------------------------- |
| BUILD_HELM (*)            | To build the helm package usually used when building the artifact. Default: no          |
| AWS_ACCESS_KEY_ID (*)     | AWS KEY for EKS.                                                                        |
| AWS_SECRET_ACCESS_KEY (*) | AWS Secret key for EKS.                                                                 |
| EKS_CLUSTER (*)           | Name of EKS cluster to deploy to.                                                       |
| VERSION (*)               | Version of artifact from the build. Used to tag docker and helm                         |
| PROJECT (*)               | Name of the application. Must match the name of the helm chart in chart/<dir>           |
| DOCKER_USER (*)           | Artifactory Docker User for helm and docker repo                                        |
| DOCKER_PASS (*)           | Artifactory Docker Password for helm and docker repo                                    |
| CHART_REPO (*)            | Root Name of helm repo in artifactory. The script appends -repo or -virt                |                                    
| ENVIRONMENT               | A deployment environment. Default: 'dev' dev|qa|prod                                    |
| AWS_REGION (*)            | AWS Region of the EKS cluster                                                           |
| DEBUG                     | Turn on extra debug information. Default: 'false'.                                      |
| APP_CONFIG                | Path from root to the applicaiton config file. Example: conf/application.yml            |
| NAMESPACE                 | Namespace to deploy to in k8s. Default: 'default'                                       |
| HELM_URL                  | Artifactory ROOT URL to push the helm package                                           |

_(*) = required variable._

## Examples

Basic example:

```yaml
script:
  - pipe: docker://myspace/bitbucket-k8-helm-pipe:latest
    variables:
      BUILD_HELM: $BUILD_HELM
      AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
      AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
      EKS_CLUSTER: $cluster_name
      VERSION: $VERSION
      PROJECT: $PROJECT
      DOCKER_USER: $DOCKER_USER
      DOCKER_PASS: $DOCKER_PASS
      CHART_REPO: $CHART_REPO
      HELM_URL:   $HELM_URL
```
 