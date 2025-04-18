FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG ZSH=/usr/share/oh-my-zsh
ARG ZSH_CUSTOM=/usr/share/oh-my-zsh/custom
ARG ZSH_THEME=risto
ARG ZSH_UPDATE=disabled
ARG ZDOTDIR=/etc/zsh

ARG PASSWORD=password

ENV LANG=zh_CN.utf8
ENV TZ=Asia/Shanghai

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
&& localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8

RUN yes | unminimize && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
apt-get install -y openssh-server zsh sudo curl wget iputils-ping vim git python3 python3-pip rsync screen traceroute net-tools iproute2 && \
rm -rf /var/lib/apt/lists/* && \
mkdir /run/sshd

RUN echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/sudo_nopasswd && \
chmod 440 /etc/sudoers.d/sudo_nopasswd

RUN echo "ubuntu:$PASSWORD" | chpasswd
#RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN sh -c "$(curl -fsSL https://install.ohmyz.sh/install.sh)" "$ZSH" --unattended && \
chmod -R 755 "$ZSH" && \
chmod -R 777 "$ZDOTDIR"

RUN echo "export ZSH=$ZSH" >> /etc/zsh/zshenv && \
echo "export ZSH_CUSTOM=$ZSH_CUSTOM" >> /etc/zsh/zshenv && \
echo "export ZDOTDIR=$ZDOTDIR" >> /etc/zsh/zshenv

RUN sed -i "s/plugins=(\(.*\))/plugins=(\1 colorize command-not-found common-aliases cp ubuntu dotenv history zsh-history-substring-search sudo git-auto-fetch jump screen ssh ssh-agent)/" "$ZDOTDIR/.zshrc" && \
echo "alias cat='ccat'\nalias less='cless'" >> "$ZDOTDIR/.zshrc" && \
echo "alias cp='cpv'" >> "$ZDOTDIR/.zshrc"

RUN apt-get update || apt-get install -y python3-pygments && rm -rf /var/lib/apt/lists/*

RUN sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"$ZSH_THEME\"/" "$ZDOTDIR/.zshrc" && \
sed -i "/^# zstyle ':omz:update' mode disabled/s/^# //g" "$ZDOTDIR/.zshrc"

RUN git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions && \
sed -i "s/plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions)/" "$ZDOTDIR/.zshrc"

RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting && \
sed -i "s/plugins=(\(.*\))/plugins=(\1 zsh-syntax-highlighting)/" "$ZDOTDIR/.zshrc"

RUN git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions && \
sed -i "/source \$ZSH\/oh-my-zsh.sh/i fpath+=\$ZSH_CUSTOM/plugins/zsh-completions/src" "$ZDOTDIR/.zshrc"

RUN git clone https://github.com/zsh-users/zsh-history-substring-search $ZSH_CUSTOM/plugins/zsh-history-substring-search && \
sed -i "s/plugins=(\(.*\))/plugins=(\1 zsh-history-substring-search)/" "$ZDOTDIR/.zshrc"

RUN chsh -s $(which zsh) ubuntu && \
chsh -s $(which zsh) root

EXPOSE 22

CMD ["sshd",  "-D"]

# docker build -t jump-server:latest .
# docker run -d --name jump-server jump-server
# docker run -d -p 2222:22 --name jump-server jump-server
# docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' jump-server
# docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t xiangrong12/jump-server:latest .
