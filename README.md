# Nginx Docker image with substitutions filter module

[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/tofran/nginx-with-substitutions-filter?sort=semver) ![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/tofran/nginx-with-substitutions-filter?sort=semver)][DockerHub]

Slim Nginx alpine Docker image with [substitution filter module](http://nginx.org/en/docs/http/ngx_http_sub_module.html).

The final result is a clean image completely based on the official `nginx:alpine`.
Does not contain any compile time junk, the only additions are: 

- Dynamic module inserted at `/usr/lib/nginx/modules/ngx_http_subs_filter_module.so`;
- Importing of the module in `/etc/nginx/nginx.conf` with `1iload_module`.


Available as `tofran/nginx-with-substitutions-filter` on [docker hub][DockerHub].

The repo could be helpful as a recipe for building images with other modules, or even as way to extract the binaries from them.


[DockerHub]: https://hub.docker.com/r/tofran/nginx-with-substitutions-filter