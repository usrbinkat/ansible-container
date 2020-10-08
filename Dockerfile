FROM docker.io/library/centos:latest as rpm
FROM registry.access.redhat.com/ubi8/ubi:latest as ubi
FROM ubi

ARG ocUrl="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz"

COPY --from=rpm /etc/pki            /etc/pki
COPY --from=rpm /etc/os-release     /etc/os-release
COPY --from=rpm /etc/yum.repos.d    /etc/yum.repos.d
COPY --from=rpm /etc/redhat-release /etc/redhat-release

ARG PIP_PKGS="\
        ansible \
        openshift \
"

ARG RPM_PKGS="\
        python3-pip \
"
RUN set -ex \
     && curl -L ${ocUrl} | tar xzvf - --directory /usr/local/bin oc \
     && chmod +x /usr/local/bin/oc \
     && /usr/local/bin/oc version \
    && echo

RUN set -ex \
     && dnf install -q -y ${RPM_PKGS} \
     && dnf clean all \
     && rm -rf /var/cache/yum \
    && echo

RUN set -ex \
     && pip3 install ${PIP_PKGS} \
    && echo

VOLUME /ansible
WORKDIR /ansible
CMD ["./run.sh"]
