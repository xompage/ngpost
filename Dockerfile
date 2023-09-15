FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

ENV \
  CUSTOM_PORT="7070" \
  TITLE="ngPost"

RUN \
  echo "**** install packages ****" && \
  sed -i 's/main$/main non-free/' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    rar \
    ca-certificates \
    xz-utils \
    tmux && \
  apt-get clean all && \
  rm -rf /var/lib/apt/lists/* && \
  echo "**** download ngpost ****" && \
  curl -o \
  /usr/local/bin/ngPost -L \
  "https://github.com/mbruel/ngPost/releases/download/v4.16/ngPost_v4.16-x86_64.AppImage" && \
  chmod +x /usr/local/bin/ngPost && \
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
