# Creating custom Docker images for use on Terra.bio

## Setting up multi-arch builds for M1 users

By default, when you build a docker image, the docker builder creates an image that will work on the architecture currently in use. If you were to build an image on a linux server, the builder would likely create an image compatible for the linux/amd64 platform, which will work seamlessly on Terra.bio. Building on an M1 Apple machine will create an image for the linux/arm64 platform, and will yield errors including “no match for platform in manifest” and other more cryptic messages. If the platform you’re building on is different from the one you plan to run the image on, you need to build a multi-architecture image.

Follow the guidance here: https://blog.jaimyn.dev/how-to-build-multi-architecture-docker-images-on-an-m1-mac/. See that blog for full details. Below is (almost verbatim) the TLDR at the end, with some updates on how to enable experimental features.

### 1 - Enable "experimental features"

In the Docker Desktop app, Settings > Docker Engine, edit the Docker daemon config file, changing

```
"experimental": false
```

to

```
"experimental": true
```

Then click `Apply & restart`

Then check that it worked:
```
$ docker version -f '{{.Server.Experimental}}'
true
```

### 2 - Setup and use `docker buildx`

Next create a new builder instance with 
```
docker buildx create --use
```
This lets you specify multiple docker platforms at once.

### 3 - Build the docker image (pushing to remote repo in the same step)

To build your Dockerfile for typical x86 systems and Apple Silicon Macs, run 

```
docker buildx build --platform=linux/amd64 --push -t <tag_to_push> .
```

Please note that you have to push directly to a repository if you want Docker Desktop to automatically manage the manifest list for you, otherwise Terra.bio will complain a lot!

Once the build is finished, it will be automatically uploaded to your configured registry. Docker will also automatically manage the manifest list for you. This allows Docker to combine the separate builds for each architecture into a single “manifest”. This means users (inlcuding Terra.bio) can do a normal docker pull <image> and the Docker client will automatically work out the correct image for their CPU architecture.

*Note: Supposedly, it's possible to specify `--platform=linux/amd64,linux/arm64` but I haven't gotten this to work on my machine. I think it's because the base `anvil-rstudio-bioconductor` image wasn't built as a multi-arch image with support for linux/arm64. To create a new linux/arm64 image (which may be useful for testing), I think you would first need to build the base image from scratch as a multi-arch image.*
