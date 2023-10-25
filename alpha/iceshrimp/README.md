## Iceshrimp

[Iceshrimp](https://iceshrimp.dev/iceshrimp/iceshrimp) is an ActivityPub based app. It's a misskey fork with hopefully less anime children 🤷 We haven't used it before, but we start with k8s first deployments for sake of future scaling.

Source helm chart: https://iceshrimp.dev/iceshrimp/iceshrimp/src/branch/dev/chart

After looking at the default values.yaml, it needs a lot of work to be secure, and they don't seem to have a hosted docker image anywhere I can find, so we'd need to build our own image, which we don't have time for right now. We will try to reach out to the devs after our matrix application set is complete, and if they're amenable, we'll help maintain their helm chart and possibly docker image.
