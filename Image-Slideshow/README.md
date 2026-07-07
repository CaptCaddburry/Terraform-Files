# Image-Slideshow
This is my latest project on building a docker image and container, utilizing a shell script to act as my main initiator to run all the commands.
---
Inside the main directory, there is the `build.sh` script to run.

It will load your environment variables stored in your `.env` file to name your docker image and tag it accordingly.

The `dockerfile` will use a multi-stage build process, first using the `cgr.dev/chainguard/python:latest-dev` image as the builder
and then using the `cgr.dev/chainguard/python:latest` image as the base.

I went with the Chainguard image over the standard DockerHub image due to wanting to ensure there weren't any open vulnerabilities in the image.

We copy over everything from the `app/web-app` directory into the image, under the directory `/app`, install our requirements, then run the `app.py` script.

The `app.py` script uses the flask module to host our `index.html` file under the initial `'/'` route.

The `index.html` file only consists of a single `div` and `img` as our main holders.
There is also a `script` block that will cycle through our listed images stored in the `app/web-app/static/images` directory
(*they should all be named '{X}.jpg*' in incremented values, ***Example: 1.jpg, 2.jpg, etc.***)

Once our image has been created, we run some `docker scout` commands to generate our SBOM, generate a vulnerability report, and to check for any critical vulnerabilities.
If there are any critical vulns, we exit out of the shell script.

After we ensure there's no critical vulns, we then run terraform to finish up running our container.
