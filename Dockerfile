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
  rm /tmp/ngpost.tar.gz && \
  echo "**** download nzbcheck source ****" && \
  mkdir /usr/src/nzbCheck && \
  curl -o \
    /tmp/nzbcheck.tar.gz -L \
    "https://github.com/mbruel/nzbCheck/archive/refs/tags/v1.2.tar.gz" && \
  tar xf \
    /tmp/nzbcheck.tar.gz -C \
    /usr/src/nzbCheck --strip-components=1 && \
  rm /tmp/nzbcheck.tar.gz
WORKDIR /usr/src/ngPost/src

ENV QT_SELECT=qt5-x86_64-linux-gnu

COPY ./root /

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
  cp /opt/NntpArticle.h ./nntp/ && \
  cp /opt/NntpArticle.cpp ./nntp/ && \
  echo "**** build ngpost ****" && \
  qmake -o Makefile ngPost.pro && \
  make -j$(nproc)

WORKDIR /usr/src/nzbCheck/src

RUN \
  echo "**** build nzbcheck ****" && \
  qmake -o Makefile nzbCheck.pro && \
  make -j$(nproc)
  
FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

ENV \
  CUSTOM_PORT="7070" \
  TITLE="ngPost"

COPY --from=builder /usr/src/ngPost /usr/src/ngPost
COPY --from=builder /usr/src/nzbCheck /usr/src/nzbCheck

RUN \
  ln -s /usr/src/ngPost/src/ngPost /usr/local/bin/ngPost && \
  ln -s /usr/src/nzbCheck/src/nzbcheck /usr/local/bin/nzbcheck && \
  echo "**** install packages ****" && \
  sed -i 's/main$/main non-free/' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    rar \
    ca-certificates \
    qtbase5-dev \
    xz-utils \
    tmux && \
  apt-get clean all && \
  rm -rf /var/lib/apt/lists/* && \
  echo "**** download parpar ****" && \
  curl -o \
  /tmp/parpar.xz -L \
  "https://github.com/animetosho/ParPar/releases/download/v0.4.2/parpar-v0.4.2-linux-static-amd64.xz" && \
  xz -d \
    /tmp/parpar.xz && \
  mv /tmp/parpar /usr/bin/parpar && \
  chmod +x /usr/bin/parpar && \
  echo "**** container tweaks ****" && \
  sed -i 's|</applications>|  <application title="ngPost*" type="regex">\n    <maximized>yes</maximized>\n  </application>\n</applications>|' /etc/xdg/openbox/rc.xml

COPY ./root /

# ports and volumes
EXPOSE 7070
VOLUME [ "/config", "/output", "/storage" ]
