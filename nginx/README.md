# Custom Nginx Image

This directory contains the Dockerfile for building a custom Nginx image that serves a file with "Hello SRE!" text.

## Features

* Based on the official nginx:alpine image
* Adds a file at `/usr/share/nginx/html/sre.txt` containing "Hello SRE!" text
* This file can be accessed via the `/sre.txt` path in a web browser

## Building the Image

To build the Docker image:

```bash
docker build -t sre-nginx:latest .
```

## Testing Locally

Run the container locally to test:

```bash
docker run -p 8080:80 sre-nginx:latest
```

Then access http://localhost:8080/sre.txt in your browser. You should see "Hello SRE!" text.

## Pushing to a Registry

Tag and push to your container registry:

```bash
docker tag sre-nginx:latest your-registry/sre-nginx:latest
docker push your-registry/sre-nginx:latest
```

Replace `your-registry` with your actual container registry URL.

## Usage in Kubernetes

The image is referenced in the Helm chart in the `k8s/helm/nginx-app` directory. 