FROM debian:jessie
MAINTAINER Alen Komljen <alen.komljen@live.com>

ENV SALT_VERSION v2016.3.5

RUN \
  apt-get update && \
  apt-get -y install \
          python-setuptools \
          vim \
          curl \
          git-core && \
rm -rf /var/lib/apt/lists/*

RUN \
  easy_install pip && \
  pip install awscli && \
  curl -L https://bootstrap.saltstack.com \
       | sh -s -- -X -L -q git "$SALT_VERSION"

COPY aws/files/aws.conf /etc/salt/cloud.providers.d/aws.conf
COPY aws/files/ubuntu_ec2.conf /etc/salt/cloud.profiles.d/ubuntu_ec2.conf
COPY aws/files/rancher.conf /etc/salt/cloud.maps.d/rancher.conf
COPY aws/files/configure_cloud.sh configure_cloud.sh

CMD ["./configure_cloud.sh"]
