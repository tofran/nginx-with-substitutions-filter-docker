# Nginx Docker image with substitutions filter module

[![Build and deploy](https://github.com/tofran/nginx-with-substitutions-filter-docker/actions/workflows/build.yaml/badge.svg)](https://github.com/tofran/nginx-with-substitutions-filter-docker/actions/workflows/build.yaml)
[![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/tofran/nginx-with-substitutions-filter?sort=semver)][DockerHub]
[![Docker Pulls](https://img.shields.io/docker/pulls/tofran/nginx-with-substitutions-filter)][DockerHub]

Slim Nginx, multi-arch alpine Docker image with [substitution filter module](http://nginx.org/en/docs/http/ngx_http_sub_module.html).

The final result is a clean image completely based on the official `nginx:alpine`.
Does not contain any compile time junk, the only additions are:

- Dynamic module inserted at `/usr/lib/nginx/modules/ngx_http_subs_filter_module.so`;
- Importing of the module in `/etc/nginx/nginx.conf` with `load_module`.

Available on [DockerHub][DockerHub] and on [GitHub container registry][GHCR]:

```sh
docker pull tofran/nginx-with-substitutions-filter
# or
docker pull ghcr.io/tofran/nginx-with-substitutions-filter
```

This repo could also be helpful as a recipe for building images with any other dynamic modules, or even as way to extract compiled binaries from them.

[DockerHub]: https://hub.docker.com/r/tofran/nginx-with-substitutions-filter
[GHCR]: https://github.com/tofran/nginx-with-substitutions-filter-docker/pkgs/container/nginx-with-substitutions-filter


## Example usage

Create the following example configuration `./sample.conf`:

```nginx
server {
    listen 80;

    location / {
        subs_filter_types text/html text/css text/xml application/javascript;
        subs_filter "nginx" "replaced";
        root /usr/share/nginx/html;
    }
}
```

Now run the image:

```sh
docker run -p 8080:80 -v ./sample.conf:/etc/nginx/conf.d/default.conf tofran/nginx-with-substitutions-filter
```

Visit `http://localhost:8080`:

![screenshot](https://github.com/user-attachments/assets/3ab17364-e517-4562-8727-2cf28b55c850)

There you go, you now have a nginx running with on-the-fly string replacement.
Happy replacing!

## License

MIT
