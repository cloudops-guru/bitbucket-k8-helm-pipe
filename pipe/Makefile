# if we are deploying with a tag it should have a version.txt instead of someone manually passing it in"
VERSIONFILE=${BITBUCKET_CLONE_DIR}/version.txt

ifeq ($(shell test -f ${VERSIONFILE} && echo -n yes),yes)
    RELEASE_VERSION :=  $(shell cat ${VERSIONFILE})
else
    RELEASE_VERSION := ${VERSION}
endif

CHART_REPO := ${CHART_REPO}
CHART_REPO_LOCAL := ${CHART_REPO}-repo
CHART_REPO_VIRT := ${CHART_REPO}-virt
CURRENT=$(pwd)
NAME := ${PROJECT}
REPO_PATH := ${BITBUCKET_CLONE_DIR}/charts/${PROJECT}

build: clean
				rm -rf ${REPO_PATH}/requirements.lock
				helm dependency build ${REPO_PATH}
				helm lint ${REPO_PATH}

install: clean build
				helm install ${REPO_PATH}/ --name ${NAME}

upgradedev: clean build release
				helm upgrade ${NAME} ${REPO_PATH}/ --install

upgradegc: clean build
				helm repo add ${CHART_REPO} ${HELM_URL}/${CHART_REPO_VIRT} --username ${DOCKER_USER} --password ${DOCKER_PASS}
				helm repo update
				helm upgrade --install -f ${REPO_PATH}/${ENVIRONMENT}-values.yaml --version ${RELEASE_VERSION} ${NAME}-${ENVIRONMENT} ${CHART_REPO}/${PROJECT}

upgradegcdev: clean build
				helm repo add ${CHART_REPO} ${HELM_URL}/${CHART_REPO_VIRT} --username ${DOCKER_USER} --password ${DOCKER_PASS}
				helm repo update
				helm upgrade --install -f ${REPO_PATH}/${ENVIRONMENT}-values.yaml --version ${RELEASE_VERSION} ${NAME}-${ENVIRONMENT} ${CHART_REPO}/${PROJECT}
				
upgradeqa: clean build
				helm repo add ${CHART_REPO} ${HELM_URL}/${CHART_REPO_VIRT} --username ${DOCKER_USER} --password ${DOCKER_PASS}
				helm repo update
				helm upgrade --install -f ${REPO_PATH}/${ENVIRONMENT}-values.yaml --version ${RELEASE_VERSION} ${NAME}-${ENVIRONMENT} ${CHART_REPO}/${PROJECT}

upgradeprod: clean build
				helm repo add ${CHART_REPO} ${HELM_URL}/${CHART_REPO_VIRT} --username ${DOCKER_USER} --password ${DOCKER_PASS}
				helm repo update
				helm upgrade --install -f ${REPO_PATH}/${ENVIRONMENT}-values.yaml --version ${RELEASE_VERSION} ${NAME}-${ENVIRONMENT} ${CHART_REPO}/${PROJECT}

delete:
				helm delete --purge ${NAME}


clean:
				rm -rf ${REPO_PATH}/charts
				rm -rf ${REPO_PATH}/${NAME}*.tgz

release: 
				helm package -d ${REPO_PATH} ${REPO_PATH}
				jfrog rt c rt-server-1 --url=${HELM_URL} --user=${DOCKER_USER} --password=${DOCKER_PASS}
				jfrog rt u ${REPO_PATH}/$(NAME)-${RELEASE_VERSION}.tgz ${CHART_REPO_LOCAL}
				rm -rf ${REPO_PATH}/${NAME}*.tgz%

tag:
				sed -i -e "s/version:.*/version: $(RELEASE_VERSION)/" ${REPO_PATH}/Chart.yaml
				sed -i -e "s/tag: .*/tag: $(RELEASE_VERSION)/" ${REPO_PATH}/values.yaml
