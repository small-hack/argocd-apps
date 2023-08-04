FROM ubuntu:latest

RUN apt-get update && apt-get install -y jq

COPY jqenv.sh /jqenv.sh

ENTRYPOINT [ "/bin/bash", "--noprofile", "--norc", "/jqenv.sh" ]
