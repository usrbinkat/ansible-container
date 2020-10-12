FROM docker.io/library/centos:latest as rpm
FROM registry.access.redhat.com/ubi8/ubi:latest as ubi
FROM ubi

COPY --from=rpm /etc/pki/           /etc/pki
COPY --from=rpm /etc/yum.repos.d/   /etc/yum.repos.d
COPY --from=rpm /etc/os-release     /etc/os-release
COPY --from=rpm /etc/redhat-release /etc/redhat-release
COPY /bin/run.sh /tmp/run.sh

RUN set -ex \
     && dnf -qy update \
     && dnf install -qy python3-pip \
     && pip3 install ansible \
     && pip3 install openshift \
     && dnf clean all \
     && echo

RUN curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz -o openshift-client-linux.tar.gz \
     && tar -xvf openshift-client-linux.tar.gz \
     && rm openshift-client-linux.tar.gz \
     && rm kubectl \
     && rm README.md \
     && mv oc /usr/local/bin

RUN mkdir /ansible

WORKDIR /ansible

CMD ["/tmp/run.sh"]
