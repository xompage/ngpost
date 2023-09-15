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
    tmux \
    make \
    g++ && \
  apt-get clean all && \
  npm i -g @animetosho/parpar && \
  rm -rf /var/lib/apt/lists/* && \
  echo "**** download ngpost ****" && \
  curl -o \
  /usr/local/bin/ngPost -L \
  "https://github.com/mbruel/ngPost/releases/download/v4.16/ngPost_v4.16-x86_64.AppImage" && \
  chmod +x /usr/local/bin/ngPost && \
  echo "**** container tweaks ****" && \
  sed -i 's|</applications>|  <application title="ngPost*" type="regex">\n    <maximized>yes</maximized>\n  </application>\n</applications>|' /etc/xdg/openbox/rc.xml

COPY ./root /

# ports and volumes
EXPOSE 7070
VOLUME [ "/config", "/output", "/storage" ]
