# Generic App Argo CD App
A generic Argo CD app using the [generic-app helm chart](https://github.com/small-hack/generic-app-helm) and the Argo CD Appset Secret Plugin.

This just allows you specify your app name and image registry/repo/tag.

## Deployment + Ingress
For something with ingress, checkout the [deployment-ingress](./deployment-ingress) directory

## Job (no deployment)
Sometimes you don't even need a deployment, you just need a job, checkout the [job](./job) directory

## Job and Deployment
Sometimes you need a deployment and job, checkout the [deployment-and-job](./deployment-and-job) directory
