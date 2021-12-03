ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

RUN apk --no-cache add -f \
  openssl \
  openssh-client \
  coreutils \
  bind-tools \
  curl \
  sed \
  socat \
  tzdata \
  oath-toolkit-oathtool \
  tar \
  libidn

ENV LE_WORKING_DIR /root/acme
ENV LE_CONFIG_HOME /data/acme
ARG AUTO_UPGRADE=1
ENV AUTO_UPGRADE $AUTO_UPGRADE

#Install
RUN curl https://get.acme.sh | sh
RUN ln -s /root/acme/acme.sh /usr/local/bin/acme.sh

# Copy data for add-on
COPY data/*.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]