FROM ubuntu:18.04
ENV HELM_BASE_URL="https://get.helm.sh"
ENV HELM_VERSION="3.0.2"
ENV HELM_TAR_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"
RUN apt-get update && apt-get install jq curl python build-essential -y
RUN curl -sO https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
RUN pip install awscli
RUN curl -Lo /usr/bin/jfrog https://api.bintray.com/content/jfrog/jfrog-cli-go/\$latest/jfrog-cli-linux-amd64/jfrog?bt_package=jfrog-cli-linux-amd64
RUN chmod +x /usr/bin/jfrog
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
&& chmod +x kubectl && mv kubectl /usr/bin/kubectl
RUN curl -L ${HELM_BASE_URL}/${HELM_TAR_FILE} |tar xvz && mv linux-amd64/helm /usr/bin/helm && chmod +x /usr/bin/helm
RUN curl -LO https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/darwin/amd64/aws-iam-authenticator && chmod +x aws-iam-authenticator \
 && mv aws-iam-authenticator /usr/bin/aws-iam-authenticator
COPY pipe /
ENTRYPOINT ["/pipe.sh"]
 