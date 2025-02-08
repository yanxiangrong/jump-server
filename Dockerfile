FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=zh_CN.utf8
ENV TZ=Etc/UTC

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8

RUN apt-get update && \
apt-get install -y openssh-server && \
mkdir /run/sshd

RUN echo 'ubuntu:password' | chpasswd
#RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 22

CMD ["sshd",  "-D"]

# docker build -t jump-server:latest .
# docker run -d --name jump-server jump-server
# docker run -d -p 2222:22 --name jump-server jump-server
# docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' jump-server