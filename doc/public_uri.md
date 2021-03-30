# Start the Service on a Public URI
You can start the service on a publicly accessible URI using the latest contents on the `master` branch.
```shell
yarn devspace:deploy production
```

Once it is deployed, you can access it at `https://<your-github-username>-<serviceName>-service.gloo.hqo.dev`
(e.g., `https://john-doe-<serviceName>-service.gloo.hqo.dev`).

You can also make any branch publicly accessible.
```shell
DOCKER_TAG=<githash for the branch> yarn devspace:deploy production
```

**NOTE**: When you no longer need the service, you **MUST** stop the service.
```shell
yarn devspace:stop
```
