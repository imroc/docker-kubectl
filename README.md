# docker-kubectl

Container image for conveniently running kubectl in a k8s pod.

## Usage

Copy [kubectl.yaml](https://raw.githubusercontent.com/imroc/docker-kubectl/refs/heads/main/kubectl.yaml) and paste it into your k8s cluster.

Then you can exec into the pod and run `kubectl`.

## Slim Image

The default image (`latest` tag) size is very large (1GB+), if you don't need that much tools, you can use the slim image (replace `latest` tag with `slim`).
