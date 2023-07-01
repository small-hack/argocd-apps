FROM debian:sid

ENV BW_CLI_VERSION=2023.1.0

RUN apt update && \
    apt install -y wget unzip && \
    wget https://github.com/bitwarden/clients/releases/download/cli-v${BW_CLI_VERSION}/bw-linux-${BW_CLI_VERSION}.zip && \
    unzip bw-linux-${BW_CLI_VERSION}.zip && \
    chmod +x bw && \
    mv bw /usr/local/bin/bw && \
    rm -rfv *.zip

COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN chmod +x /usr/bin/entrypoint.sh

# create a user for non-root operation
ARG USER="user"
RUN useradd -ms /bin/bash $USER && \
        mkdir -p /home/$USER/.local/bin && \
        mkdir -p /home/$USER/.local/lib && \
        chown -R $USER:$USER /home/$USER/

# Swap to user account
USER $USER
WORKDIR /home/$USER/

CMD ["/bin/bash", "/usr/bin/entrypoint.sh"]
