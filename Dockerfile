# Use the following images as parent images
FROM docker.io/library/centos:latest as rpm
FROM registry.access.redhat.com/ubi8/python-38 as ubi
FROM ubi

# Run as USER
USER root

# Copy YUM Repo data from the CentOS donor container to the ansible container
COPY --from=rpm /etc/pki            /etc/pki
COPY --from=rpm /etc/os-release     /etc/os-release
COPY --from=rpm /etc/yum.repos.d    /etc/yum.repos.d
COPY --from=rpm /etc/redhat-release /etc/redhat-release

# Load Entrypoint
COPY entrypoint /bin/entrypoint

# OC URL 
ARG ocUrl="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz"

# PKG Lists
ARG PIP_PKGS="\
        ansible \
        molecule \
        paramiko \
        openshift \
        kubernetes \
"
ARG DNF_PKGS="\
        git \
"

# CMD Flags
ARG PIP_FLAGS="\
        --use-feature=2020-resolver \
"
ARG DNF_FLAGS="\
        -y \
        --nobest \
        --allowerasing \
        --setopt=tsflags=nodocs \
        --disablerepo "ubi-8-appstream" \
        --disablerepo="ubi-8-codeready-builder" \
        --disablerepo="ubi-8-baseos" \
"

# Create base directory tree
RUN set -ex \
     && mkdir -p \
          /ansible \
     && echo

# Update pip packages & install auxiliary packages if declared
RUN set -ex \
     && pip install --upgrade pip \
     && pip install ${PIP_PKGS} ${PIP_FLAGS} \
     && ansible --version \ 
     && echo

# Update dnf packages & install auxiliary packages if declared
RUN set -ex \
     && dnf update \
     && dnf install ${DNF_FLAGS} ${DNF_PKGS} \
     && dnf clean all \
     && rm -rf /var/cache/yum \
     && git version \
     && echo

# Downloading oc client binary
RUN set -ex \
     && curl -L ${ocUrl} | tar xzvf - --directory /usr/local/bin oc \
     && chmod +x /usr/local/bin/oc \
     && oc version \
     && echo

ENTRYPOINT ["entrypoint"]
WORKDIR /ansible
