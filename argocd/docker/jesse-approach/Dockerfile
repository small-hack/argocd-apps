FROM python:3.11-slim-bookworm

# install any security updates we need
RUN apt-get update && \
    apt list --upgradeable | grep security | cut -f1 -d '/' | xargs apt-get install --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

COPY python_plugin.py /python_plugin.py

ENTRYPOINT ["python", "/python_plugin.py"]
