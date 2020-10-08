FROM docker.io/library/centos:latest as rpm
FROM registry.access.redhat.com/ubi8/ubi:latest as ubi
FROM ubi

ARG ocUrl="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz"

COPY --from=rpm /etc/pki/           /etc/pki
COPY --from=rpm /etc/yum.repos.d/   /etc/yum.repos.d
COPY --from=rpm /etc/os-release     /etc/os-release
COPY --from=rpm /etc/redhat-release /etc/redhat-release

RUN set -ex \
     && dnf -qy update \
     && dnf install -qy python3-pip \
     && pip3 install ansible \
     && pip3 install openshift \
     && dnf clean all \
    && echo

RUN set -ex \
     && curl -L ${ocUrl} | xzvf - --directory /usr/local/bin oc \
     && chmod +x /usr/local/bin/oc \
    && echo

VOLUME /ansible
WORKDIR /ansible
CMD ["./run.sh"]
