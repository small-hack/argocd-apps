# Argo CD app for Home Assistant

Home Assistant is a home IOT management solution. We're looking at existing helm charts like:
https://github.com/volker-raschek/home-assistant-charts/tree/master

But we may end up just using the existing docker file mentioned [here](https://www.home-assistant.io/installation/alternative#docker-compose) to just deplooy a series of manifests we need for this:
```
ghcr.io/home-assistant/home-assistant:stable
```
