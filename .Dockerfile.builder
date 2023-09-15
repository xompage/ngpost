# Builder
FROM ghcr.io/linuxserver/baseimage-debian:bullseye as builder

RUN \
  echo "**** download ngpost source ****" && \
  mkdir /usr/src/ngPost && \
  curl -o \
    /tmp/ngpost.tar.gz -L \
    "https://github.com/mbruel/ngPost/archive/refs/tags/v4.16.tar.gz" && \
  tar xf \
    /tmp/ngpost.tar.gz -C \
    /usr/src/ngPost --strip-components=1 && \
  rm /tmp/ngpost.tar.gz
WORKDIR /usr/src/ngPost/src

ENV QT_SELECT=qt5-x86_64-linux-gnu

RUN \
  echo "**** install packages ****" && \
  sed -i 's/main$/main non-free/' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    git \
    build-essential \
    qt5-qmake \
    qtbase5-dev \
    par2 \
    rar \
    ca-certificates && \
  rm -rf /var/lib/apt/lists/* && \
  echo "**** build ngpost ****" && \
  qmake -o Makefile ngPost.pro && \
  make -j$(nproc)


# Run
FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

ENV \
  CUSTOM_PORT="7070" \
  TITLE="ngPost"

COPY --from=builder /usr/src/ngPost /usr/src/ngPost

RUN \
  sed -i 's/main$/main non-free/' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    rar \
    ca-certificates \
    qtbase5-dev \
    tmux \
    build-essential && \
  apt-get clean all && \
  npm i -g @animetosho/parpar && \
  rm -rf /var/lib/apt/lists/* && \
  ln -s /usr/src/ngPost/src/ngPost /usr/local/bin/ngPost && \
  sed -i 's|</applications>|  <application title="ngPost*" type="regex">\n    <maximized>yes</maximized>\n  </application>\n</applications>|' /etc/xdg/openbox/rc.xml

COPY ./root /

# ports and volumes
EXPOSE 7070
VOLUME [ "/config", "/output", "/storage" ]
