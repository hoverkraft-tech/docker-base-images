# ci-helm

A image for helm chart-testing (helm ct) with some handy tools added

- yq
- jq
- cURL
- OpenSSL
- Git
- kubeconform, supplied by a version-pinned upstream image for AMD64 and ARM64

The `kubeconform` Helm plugin uses the bundled kubeconform binary.
The `schema` Helm plugin generates JSON schemas for chart values.

We also add some scripts to make life easier :

All the scripts are located in /usr/local/bin (which is in the shell default path)

| script    | purpose                                                     |
| --------- | ----------------------------------------------------------- |
| helm-deps | automatically download helm dependencies in an arborescence |

## Usage

To use the image, you can pull it from the [OCI registry](https://github.com/orgs/hoverkraft-tech/packages/container/package/docker-base-images%2Fci-helm).
