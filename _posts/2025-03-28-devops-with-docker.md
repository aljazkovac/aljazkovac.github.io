---
title: DevOps with Docker
date: 2025-03-28 09:30:00 +0200
categories: [devops, docker] # TOP_CATEGORY, SUB_CATEGORY, MAX 2.
tags: [devops, docker, containers] # TAG names should always be lowercase.
description: A comprehensive course on Docker offered by University of Helsinki
---

Since I started working with DevOps at my current job at [Caspeco](https://caspeco.com/) (I started there in September 2022, and transitioned into a 
more of a DevOps role in late 2023), I have been working a lot with containers. We started moving towards a microservices
architecture, so a lot of my work has revolved around creating smaller services that we deploy as container apps in Azure.
The reason for taking [this course](https://courses.mooc.fi/org/uh-cs/courses/devops-with-docker) has therefore been to complement the knowledge and skills I learned at my work, with whatever
this course could teach me. I have good experience with University of Helsinki
courses (took their [Full Stack Open](https://aljazkovac.github.io/posts/Full-Stack-Open-Deep-Dive-Into-Modern-Web-Development/) course a while ago), 
so I look forward to this one!

## Chapter 1: Getting started

This chapter is just about some general course information and setting up Docker, etc. But what I really loved was 
the [preamble on LLMs](https://courses.mooc.fi/org/uh-cs/courses/devops-with-docker/chapter-1) and their role in software development, 
and how a programmer should approach working with them. I really recommend reading it. 
Here is just a little taste to whet your appetite:

> The rapid development of language models puts the student in a challenging position: is it worth and is it even necessary 
> to learn things at a detailed level, when you can get almost everything ready-made from language models?
At this point, it is worth remembering the old wisdom of Brian Kerningham, co-author of The C Programming Language:
> 
> __"Everyone knows that debugging is twice as hard as writing a program in the first place. So if you're as clever as you can be
when you write it, how will you ever debug it?"__
> 
> In other words, since debugging is twice as difficult as programming, it is not worth programming such code that you can only barely understand. How can debugging be even possible in a situation where programming is outsourced to a language model and the software developer does not understand the debugged code at all? The exact same thing applies to configuring Docker and might actually be even more severe, if you do not understand the fundamentals, debugging hard Docker related issues is just impossible.

I couldn't agree more! I think the need to learn the basics well is greater now than ever. Recent research shows that GitHub Copilot
has negatively affected code quality since its widespread adoption. I personally don't use any code completion when I code anymore. 
It's like somebody constantly trying to finish your sentences. It is impossible to get any quality work done. I do, however,
use LLMs extensively when researching something or trying to learn the basics of something completely new. I do think they can be
a great tool, if used correctly.

## Chapter 2: Docker basics

### Definitions and basic concepts

#### DevOps and Docker

DevOps (Dev == development, Ops == operations) simply means that the release, configuring and monitoring of software is in the hands
of the people who develop it.

> Docker is a set of platform as a service (PaaS) products that use OS-level virtualization to deliver software in packages 
> called containers.
> — ([Wikipedia](https://en.wikipedia.org/wiki/Docker_(software)))

Some of the benefits of containers:

1. They mitigate the "works on my machine" problem (if you also develop locally using containers, of course)
2. Isolated environments: you can run applications that require different runtime environments
3. Development: no need to install a bunch of services on your local machine, just spin them up inside a container!
4. Scaling: easy to spin up multiple containers at once and load balance traffic between them

The difference between Virtual Machines (VMs) and containers is that VMs run on a [hypervisor](https://en.wikipedia.org/wiki/Hypervisor), 
which virtualizes the physical hardware. 

> Each VM includes a full operating system (OS) along with the necessary binaries and libraries, making them heavier and more 
> resource-intensive. Containers, on the other hand, share the host OS kernel and only package the application and its dependencies, 
> resulting in a more lightweight and efficient solution.
> — ([Devops with Docker](https://courses.mooc.fi/org/uh-cs/courses/devops-with-docker/chapter-2/definitions-and-basic-concepts))

Containers therefore offer faster startup times and less overhead, but less isolation than VMs (the isolation level of containers 
is at the process level, not the OS level).

__Side note:__ Docker can run natively only on Linux! Docker for Mac actually uses a VM that runs a Linux instance under the hood!

#### Images and containers

Containers are instances of images. 
Cooking metaphor:

Image == recipe + ingredients
Container == finished meal.

To run a container you need an image and a container runtime (Docker engine). The image provides the instructions (recipe) 
and dependencies (ingredients) for the container to run.

---

__Image__

An image is a file and cannot be changed. An image has a base layer and then additional layers. Images are created from
an instructional file called a `Dockerfile` that is parsed when running `docker image build`. A Dockerfile is therefore
a recipe for creating an image! (Just as an image is a recipe for creating a container)

_Important commands_: 
- `docker image ls`
- `docker image build`

---

---

__Container__

Containers are created from images.

> Containers only contain what is required to execute an application; and you can start, stop and interact with them. 
> They are isolated environments in the host machine with the ability to interact with each other and the host machine itself 
> via defined methods (TCP/UDP).
> — ([Devops with Docker](https://courses.mooc.fi/org/uh-cs/courses/devops-with-docker/chapter-2/definitions-and-basic-concepts))

_Important commands_:
- `docker container ls (-a)` or the shorter `docker ps`

---

#### Docker CLI basics

When we use the command line to interact with Docker we are actually interacting with the "Docker Engine", which consists
of:

- CLI client
- a REST API
- Docker daemon

Here is the workflow: 

```
run command -> CLI sends request through the REST API to Docker daemon -> Docker daemon handles the request.
```

To remove an image, you need to first remove the referencing container. 

_Important commands_:

| Command                             | Explain                                 | Shorthand       |
|-------------------------------------|-----------------------------------------|-----------------|
| `docker image ls`                   | Lists all images                        | `docker images` |
| `docker image rm <image>`           | Removes an image                        | `docker rmi`    |
| `docker image pull <image>`         | Pulls image from a docker registry      | `docker pull`   |
| `docker container ls -a`            | Lists all containers                    | `docker ps -a`  |
| `docker container run <image>`      | Runs a container from an image          | `docker run`    |
| `docker container rm <container>`   | Removes a container                     | `docker rm`     |
| `docker container stop <container>` | Stops a container                       | `docker stop`   |
| `docker container exec <container>` | Executes a command inside the container | `docker exec`   |
| `docker container prune`            | Removes all stopped containers          |                 | 
| `docker image prune`                | Removes all dangling images             |                 | 

#### Exercises

---

__Ex. 1.1.__

```bash
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker container run -d nginx 
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker container run -d nginx 
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker container run -d nginx 
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker ps 
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS     NAMES 
9caf673c6322   nginx     "/docker-entrypoint.…"   3 seconds ago   Up 2 seconds   80/tcp    magical_napier 
500c35b530e2   nginx     "/docker-entrypoint.…"   5 seconds ago   Up 4 seconds   80/tcp    wonderful_elbakyan 
a3f9a37b6036   nginx     "/docker-entrypoint.…"   9 seconds ago   Up 7 seconds   80/tcp    funny_hoover 
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker container stop magical_napier 
magical_napier 
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker container stop wonderful_elbakyan 
wonderful_elbakyan 
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker ps -a 
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS                      PORTS     NAMES 
9caf673c6322   nginx     "/docker-entrypoint.…"   43 seconds ago   Exited (0) 19 seconds ago             magical_napier 
500c35b530e2   nginx     "/docker-entrypoint.…"   45 seconds ago   Exited (0) 12 seconds ago             wonderful_elbakyan 
a3f9a37b6036   nginx     "/docker-entrypoint.…"   49 seconds ago   Up 48 seconds               80/tcp    funny_hoover 
```

---

---

__Ex. 1.2.__

_Solution_

```bash
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker ps 
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS     NAMES 
a3f9a37b6036   nginx     "/docker-entrypoint.…"   6 minutes ago   Up 6 minutes   80/tcp    funny_hoover 
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker stop funny_hoover 
funny_hoover 
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker image ls 
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE 
nginx        latest    678546cdd20c   4 weeks ago   197MB 
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker rm funny_hoover 
funny_hoover 
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker container prune 
WARNING! This will remove all stopped containers. 
Are you sure you want to continue? [y/N] y 
Deleted Containers: 
9caf673c63227c18914ce027dbb144f541888f8042fd2a88b89525aa5c318808 
500c35b530e28f0021b84d8edc038c8504a4f8fad3e32cf016518b8b22e1aa3a 
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker rmi nginx 
Untagged: nginx:latest 
Untagged: nginx@sha256:9d6b58feebd2dbd3c56ab5853333d627cc6e281011cfd6050fa4bcf2072c9496 
Deleted: sha256:678546cdd20cd5baaea6f534dbb7482fc9f2f8d24c1f3c53c0e747b699b849da 
Deleted: sha256:cab207776f194b355b5c3a18b7e53be9627cb73dc39d2912e231ef99953dc41c 
Deleted: sha256:c336c8c4c4288abf4eae3c08633fac049917cfb366fad891c4ed74c94b7b0017 
Deleted: sha256:8eaa3047f3c86725e6711ea52d2a96b3e3a36a930d521f0c7cc049128ef1dda0 
Deleted: sha256:6ca5a3876c2d60859bdacfad260ef2efa4c03f505c686367aaa211cca7996ce5 
Deleted: sha256:e48be8c89956855bb905f19f3efb3d591623a1ee0a7f484b016267a16983c225 
Deleted: sha256:666d17913d2acdfad20fdd2b47b5564ea1660c410cde43e6326bc76598dc2194 
Deleted: sha256:52d51720ba2d06cecaed7505a36dbdf74d33d70a2e064ed714f88fe08fd403de 
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker image ls 
REPOSITORY   TAG       IMAGE ID   CREATED   SIZE 
(base) aljazkovac@Aljazs-MacBook-Pro ~ % docker ps -a     
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES 
(base) aljazkovac@Aljazs-MacBook-Pro ~ %  
```

---

### Running and stopping containers

Run `docker run -d -it --name looper ubuntu sh -c 'while true; do date; sleep 1; done'`

- `-d` == detached
- `-it` == interactive and [tty](https://en.wikipedia.org/wiki/Tty_(Unix))
- `sh -c` = shell command

---

_Important commands_:

| Command                                | Explain                           | Shorthand       |
|----------------------------------------|-----------------------------------|-----------------|
| `docker container logs (-f)`           | Lists (or follows) the logs       | `docker logs`   |
| `docker container pause`               | Pauses the container              |                 | 
| `docker container unpause`             | Unpauses the container            |                 | 
| `docker container attach (--no-stdin)` | Attaches to the container         | `docker attach` | 
| `docker exec`                          | Executes command inside container |                 | 

---

If we attach to a container without the `no-stdin` flag and exit with `CTRL + c` then we will stop the container. 

To execute commands within the container, use `docker exec <container>`. For example, to run bash you could do 
`docker exec -it <container> bash`

Here is a more complicated command:
`$ docker run -d --rm -it --name looper-it ubuntu sh -c 'while true; do date; sleep 1; done'`

The `--rm` flag removes the container after it has stopped. If we attach to the container with `docker attach looper-it`
and then press the escape sequence `CTRL+P, CTRL+Q` we will exit the container without killing it. If we exit with `CTRL+C` 
then we kill the container, which also removes it (due to the `--rm` flag).

We install new tools inside a container, e.g., Vim, by running:

- `docker run -it ubuntu`
- `apt-get update`
- `apt-get -y install vim`

But the installation done in this way will not be permanent!

#### Exercises

__Ex. 1.3.__

_Solution_

```bash
1. docker run -d --rm -it --name secret-msg devopsdockeruh/simple-web-service:ubuntu
2. docker exec -it secret-msg bash
3. tail -f ./text.log
```

__Ex. 1.4.__
_Solution_

```bash
docker run -it --name curl ubuntu sh -c 'while true; do echo "Input website:"; read website; echo "Searching.."; sleep 1; curl http://$website; done' - this results in 'curl not found'

To fix the problem:

1. docker start curl
2. docker exec -it curl bash
3. apt-get update
4. apt-get -y install curl

Exit the container and test if the solution works:
docker exec -it curl sh -c 'while true; do echo "Input website:"; read website; echo "Searching.."; sleep 1; curl http://$website; done'

Result:
Input website:
helsinki.fi
Searching..
<html>
<head><title>301 Moved Permanently</title></head>
<body>
<center><h1>301 Moved Permanently</h1></center>
<hr><center>nginx/1.24.0</center>
</body>
</html>
Input website:
```

### In-depth dive into images

#### Where do the images come from?

When we want to find an image to pull we can use the `docker search` command to look for images. The official images are
marked as such. We can pull a certain tag of an image like so: `docker pull <image>:<tag>`. 

### A detailed look into an image

Let's pull a certain tag of the Ubuntu image with `docker pull ubuntu:24.04`. We get this if we run `docker image ls`:

```bash
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
ubuntu       24.04     c3d1a3432580   6 weeks ago   101MB
```

If we then run `docker tag ubuntu:24.04 ubuntu:noble_numbat` we get this:

```bash
REPOSITORY   TAG            IMAGE ID       CREATED       SIZE
ubuntu       24.04          c3d1a3432580   6 weeks ago   101MB
ubuntu       noble_numbat   c3d1a3432580   6 weeks ago   101MB
```

And running `docker tag ubuntu:24.04 fav_distro:noble_numbat` gives us this:

```bash
REPOSITORY   TAG            IMAGE ID       CREATED       SIZE
fav_distro   noble_numbat   c3d1a3432580   6 weeks ago   101MB
ubuntu       24.04          c3d1a3432580   6 weeks ago   101MB
ubuntu       noble_numbat   c3d1a3432580   6 weeks ago   101MB
```

An image name therefore consists of three parts and a tag: `registry/organisation/image:tag`. 
If it's just a short name, like `ubuntu` then we have these defaults:

```
registry = docker hub
organisation = library
tag = latest
```

If you have the same image with several tags, then you need to specify the image and the tag to untag it, e.g. 
`docker rmi fav_distro:noble_numbat`. Otherwise, you will get the error 
`unable to delete c3d1a3432580 (must be forced) - image is referenced in multiple repositories`.

#### Building images

To build an image, we use a [Dockerfile](https://docs.docker.com/reference/dockerfile/), which is simply 
a set of instructions for an image.

Let us generate this script:

```sh
#!/bin/sh

echo "Hello Docker!"
```

Give it executable permissions:

```bash
chmod +x hello.sh
```

And use this Dockerfile:

```dockerfile
# Start from the alpine image that is smaller but no fancy tools
FROM alpine:3.21

# Use /usr/src/app as our workdir. The following instructions will be executed in this location.
WORKDIR /usr/src/app

# Copy the hello.sh file from this directory to /usr/src/app/ creating /usr/src/app/hello.sh
# COPY <src> <dest> - Copies files from source to destination in container
# The . at the end means copy to current working directory (/usr/src/app)
COPY hello.sh .

# Alternatively, if we skipped chmod earlier, we can add execution permissions during the build.
# RUN chmod +x hello.sh

# When running docker run the command will be ./hello.sh
CMD ./hello.sh
```

And let's build using this instruction:

```bash
docker build . -t hello-docker
```

This command:
- `.` tells Docker to look for the Dockerfile in the current directory
- `-t hello-docker` tags the image with the name "hello-docker"

The build output shows three steps, which correspond to three layers that constitute this image:

```bash
 => [1/3] FROM docker.io/library/alpine:3.21@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88
 => [internal] load build context                                                                                  
 => => transferring context: 66B                                                                                   
 => CACHED [2/3] WORKDIR /usr/src/app                                                                              
 => CACHED [3/3] COPY hello.sh .                                                                                   
```

Layers can act as cache, which means that if we just change the last lines of our Dockerfile, the first two layers of the image can 
remain unchanged. This can help us build faster pipelines!

Then we can simply run a container from the image with `docker run hello-docker`. 

Let us manually create new layers on top of an image.

We begin by running the container interactively with `docker run -it hello-docker sh`. Then, in another terminal, we do:

```bash
touch additional.txt
docker cp additional.txt mystifying_elion:/usr/src/app
```

In another terminal we can check that the file has been created and can see what has changed with `docker diff <container>`:

```sh
C /root
A /root/.ash_history
C /usr
C /usr/src
C /usr/src/app
A /usr/src/app/additional.txt
```

We can then commit the changes with the command `docker commit <container> <new-image-name>`.

However, it is much better to simply change the Dockerfile and add the new text file there. We add this 
to the Dockerfile:

```dockerfile
RUN touch additional.txt
```

We can build a new image with `docker build . -t hello-docker:v2`. Then we can run `docker run hello-docker:v2 ls` 
and see that the file has been added.

---

_Important commands_:

| Command          | Explain                            | Shorthand |
|------------------|----------------------------------- |-----------|
| `docker search`  | Searches for images on Docker hub  |           |
| `docker diff`    | Lists file changes in a container  |           |
| `docker commit`  | Commits a container's file changes |           |

__Note__: All commands in a Dockerfile except `CMD` and TODO: FILL HERE! are executed during build time. 
CMD and FILL HERE is executed at runtime.

---

#### Exercises

---

__Ex. 1.7.__

_Solution_

```dockerfile
# Start from the ubuntu image
FROM ubuntu:24.04

# Use /usr/src/app as our workdir. The following instructions will be executed in this location.
WORKDIR /usr/src/app

# Install curl
RUN apt-get update
RUN apt-get -y install curl

# Copy the file from this directory to /usr/src/app/
COPY script.sh .

# Add execution permissions on the file
RUN chmod +x script.sh

# When running docker run the command will be the one defined here
CMD ./script.sh
```

---

---

__Ex. 1.8.__

_Solution_

# Start from the ubuntu image
FROM devopsdockeruh/simple-web-service:alpine

# When running docker run the command will be the one defined here
CMD server

---

### Defining start conditions for the container

Instead of simply adding stuff to the Dockerfile, without really knowing if it's going to work, 
let's try another approach: test stuff first before committing it to our Dockerfile.

Once we know what we need, we add it to the Dockerfile. __Important__: Add the stuff that is most prone
to change at the bottom. This way we can save our cached layers.

---

__CMD vs Entrypoint__

The difference between CMD and ENTRYPOINT:

- `ENTRYPOINT` defines the executable that will always run when the container starts
- `CMD` provides default arguments to the `ENTRYPOINT`, or specifies the entire command if no `ENTRYPOINT` is defined
- `CMD` can be overridden from the command line, while `ENTRYPOINT` requires the --entrypoint flag to override

Use `docker inspect`to inspect the image and its defined `CMD`and `ENTRYPOINT`.

For example, observe the following Dockerfile:

```dockerfile
FROM ubuntu:24.04

WORKDIR /mydir

RUN apt-get update && apt-get install -y curl python3
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
RUN chmod a+x /usr/local/bin/yt-dlp

# If we used CMD instead of ENTRYPOINT:
# - Any arguments passed to 'docker run' would completely override the command
# - With ENTRYPOINT, arguments are appended to the command instead
ENTRYPOINT ["/usr/local/bin/yt-dlp"]

# If we add a command here then we can run the container without a specific argument
# If we do specify an argument then it overrides this, the default, one
CMD ["https://www.youtube.com/watch?v=Aa55RKWZxxI"]
```

__Shell vs Exec form__

_Shell form_ (`ENTRYPOINT command param1 param2`):
- Runs command in a shell (`/bin/sh -c`)
- Can use shell features (environment variables, pipes, etc.)
- Example: `ENTRYPOINT echo "Hello $NAME"`

_Exec form_ (`ENTRYPOINT ["command", "param1", "param2"]`):
- Runs command directly without shell
- More efficient (no shell overhead)
- Cannot use shell features directly
- Example: `ENTRYPOINT ["/usr/local/bin/app", "--port", "8080"]`

_Example_:

```dockerfile
# Shell form - using && and environment variable
ENTRYPOINT mkdir -p /data/$FOLDER && echo "Created folder" && ls /data
```

If we run 
```bash
docker run -e FOLDER=logs myimage
# Creates /data/logs, prints "Created folder", and lists contents
```
then this would work.

Exec form would not work:
```dockerfile
# Exec form - cannot use && or $FOLDER
ENTRYPOINT ["mkdir", "-p", "/data/$FOLDER", "&&", "echo", "Created folder", "&&", "ls", "/data"]
```

This would fail because:
1. $FOLDER won't be evaluated
2. && isn't valid as a command argument

To use environment variables with exec form, you'd need to define the shell explicitly:

```dockerfile
ENTRYPOINT ["/bin/sh", "-c", "mkdir -p /data/$FOLDER && echo 'Created folder' && ls /data"]
```

__Best practice__: Use exec form unless shell features are needed, and keep the same form for both ENTRYPOINT and CMD.

---

_Important commands_:

| Command                                        | Explain                                                                 | Shorthand |
|------------------------------------------------|-------------------------------------------------------------------------|-----------|
| `docker inspect <container/image>`             | Shows detailed information about a container or image in JSON format    |           |
| `docker cp <container>:<src-path> <dest-path>` | Copies files/folders between a container and local filesystem           |           |

### Interacting with the container via volumes and ports

Instead of using the `docker cp` command to copy files from a container to local disk, we can use 
[Docker volumes](https://docs.docker.com/engine/storage/volumes/) and [bind mounts](https://docs.docker.com/engine/storage/bind-mounts/):

--- 

__Docker Storage: Volumes vs Bind Mounts__

_Volumes_
- Managed by Docker (`/var/lib/docker/volumes/`)
- Portable and easier to backup
- Independent of host machine directory structure
- Ideal for production use

Use _Volumes_ for:
- Persisting application data
- Sharing data between containers
- Production environments
- Data backups and migrations

_Bind Mounts_
- Direct mapping to host machine paths
- Files accessible directly on host system
- Perfect for development environments
- Host machine directory structure dependent

Use _Bind Mounts_ for:
- Development environments
- Quick code changes
- Configuration files
- When direct host machine access is needed

---

We can run a container from the `yt-dlp` image and bind our local directory to it like so:

```bash
$ docker run -v "$(pwd):/mydir" yt-dlp https://www.youtube.com/watch?v=saEpkcVi1d4
```

We have mounted our current folder as `/mydir`in the container, so that the video is saved to our
local machine instead of the `/mydir`folder in the container. We could also mount just a specific file,
e.g., `-v "$(pwd)/material.md:/mydir/material.md"`.


#### Allowing external connections into containers

Programs can send messages to URL addresses, and they can be assigned to listen to any available port.
The address `127.0.0.1` is also known as `localhost`. They always refer to the host on which they are
sent or received.

To open a connection to a Docker container we do the following:

1. _Expose port_ (add `EXPOSE <port>` to the Dockerfile)
2. _Publish port_ (run the container with `-p <host-port>:<container-port>`)

__CAREFUL__: this short snytax, `-p <host-port>:<container-port>` basically results in 
`-p 0.0.0.0:<host-port>:<container-port>`, which opens the port to anyone!

You can also limit connections to a certain protocol, e.g., `EXPORT <port>/UDP` and `p <host-port>:<container-port>/udp`.

#### Exercises

---

__Ex. 1.9.__

_Solution_

I created the `logs.log` file first with `touch logs.log`, otherwise the `-v flag` command would create a directory. 

Then I ran:

`docker run -v "$(pwd)/logs.log:/usr/src/app/text.log" devopsdockeruh/simple-web-service`

---

---

__Ex. 1.10.__

_Solution_

```bash
docker run -p 127.0.0.1:8080:8080 web-server
```

---

### Utilizing tools from the Registry

Observe the following Dockerfile, which containerizes a [Ruby on Rails project](https://github.com/docker-hy/material-applications/tree/main/rails-example-project):

```dockerfile
# We need ruby 3.1.0. I found this from Docker Hub
FROM ruby:3.1.0

EXPOSE 3000

WORKDIR /usr/src/app

# Install the correct bundler version
RUN gem install bundler:2.3.3

# Copy the files required for dependencies to be installed
# Copy these files separately to take advantage of Docker's caching mechanism
COPY Gemfile* ./

# Install all dependencies
RUN bundle install

# Copy all of the source code
COPY . .

# We pick the production mode since we have no intention of developing the software inside the container.
# Run database migrations by following instructions from README
RUN rails db:migrate RAILS_ENV=production

# Precompile assets by following instructions from README
RUN rake assets:precompile

# And finally the command to run the application
CMD ["rails", "s", "-e", "production"]
```

If you pay attention you will see it closely follows the [README file](https://github.com/docker-hy/material-applications/blob/main/rails-example-project/README.md) in the project.


#### Exercises 

---

__Ex. 1.11.__

The goal of this exercise is to containerize an old [Java Spring project](https://github.com/docker-hy/material-applications/tree/main/spring-example-project).

_Solution_

```dockerfile
FROM amazoncorretto:8

EXPOSE 8080

WORKDIR /usr/src/app

COPY . .

RUN ./mvnw package

CMD [ "java", "-jar", "./target/docker-example-1.1.3.jar" ]
```

Then use the following command:

```bash
docker build . -t java-project && docker run -p 127.0.0.1:8080:8080 java-project
```

---

#### Project Exercises

---

__Ex. 1.12.__

_Solution_

```dockerfile

FROM node:16.20.2-bullseye-slim

WORKDIR /usr/src/app

# Port 5000 is reserved on my MacBook, so using port 3000 instead
EXPOSE 3000

COPY . .

RUN npm install

RUN npm run build

RUN npm install -g serve

CMD [ "serve", "-s", "-l", "3000", "build" ]


```

Then use this to run:

```bash
docker build . -t project-frontend && docker run -p 127.0.0.1:3000:3000 project-frontend
```

---

---

__Ex. 1.13.__

_Solution_

```dockerfile
FROM golang:1.16-bullseye

WORKDIR /usr/src/app

EXPOSE 8080

COPY . .

RUN go build

RUN go test ./...

CMD [ "./server" ]
```

Then run this: 

```bash
docker build --platform linux/amd64 -t project-backend . && docker run -p 127.0.0.1:8080:8080 project-backend
```

---

---

__Ex. 1.14.__

_Solution_

Dockerfile for the frontend:

```dockerfile
FROM node:16.20.2-bullseye-slim

WORKDIR /usr/src/app

# Port 5000 is reserved on my MacBook, so using port 3000 instead
EXPOSE 3000

COPY . .

RUN npm install

ENV REACT_APP_BACKEND_URL=http://localhost:8080

RUN npm run build

RUN npm install -g serve

CMD [ "serve", "-s", "-l", "3000", "build" ]
```

Dockerfile for the backend:

```dockerfile
FROM golang:1.16-bullseye

WORKDIR /usr/src/app

EXPOSE 8080

COPY . .

ENV REQUEST_ORIGIN=http://localhost:3000

RUN go build

RUN go test ./...

CMD [ "./server" ]
```

Command to build and run the frontend: 

```bash
docker build . -t project-frontend && docker run -p 127.0.0.1:3000:3000 project-frontend
```

```bash
docker build --platform linux/amd64 -t project-backend . && docker run -p 127.0.0.1:8080:8080 project-backend
```

---

---

__Ex. 1.15.__

_Solution_

I had an LLM build my a simple Razor .NET web app where one can post messages in a simple GUI. Then I
containerized it and published it to [Docker Hub](https://hub.docker.com/repository/docker/aljazkovac/project-homework/general)

Here is the Dockerfile I used:

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /usr/src/app

COPY . .

RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app

COPY --from=build /app/publish .

EXPOSE 8080

CMD [ "dotnet", "SimpleMessageBoard.dll" ]
```

---

---

__Ex. 1.16.__

_Solution_

I have deployed the app from the previous ex. (1.15) to DigitalOcean. 
I built the image and ran it locally like this:

```bash
docker build --platform linux/amd64 -t project-homework . && docker run -p 127.0.0.1:8080:8080 project-homework
```

Then I created a repository on Docker hub called [aljazkovac/project-homework](https://hub.docker.com/repository/docker/aljazkovac/project-homework/general) and pushed the image there.

On [DigitalOcean](https://www.digitalocean.com/) I then created a webapp and simply connected it to the image 
I pushed to Docker Hub. Then it was easy to deploy via the GUI there, and you can access the running app 
[here](https://messages-app-homework-n7x9w.ondigitalocean.app/)(if it no longer works then it's because
the exercise has been graded and I destroyed the resource to not have to pay for it). But you can always
pull the image locally from Docker Hub and run it there!

---

### Summary

In this chapter we learned the basics of containers and images. We learned how to write simple Dockerfiles,
and how to use their caching mechanism to our advantage. We have also learned how to push images to Docker Hub,
where they can be pulled by other users. 

### Certificate of completion

![DevOps with Docker: Docker basics](/assets/images/devops-docker/devops-docker-basics-certificate.png)
_Certificate for completing the Docker basics part of the DevOps with Docker course_

Validate the certificate at the [validation link](https://courses.mooc.fi/certificates/validate/7sb5eqwntiyyxcg).

## Chapter 3: Docker compose

### Basics of docker compose

We will be using [Docker Compose](https://docs.docker.com/compose/) to define and run multi-container applications.

| Command               | Explain                           |
|-----------------------|-----------------------------------|
| `docker compose up`   | Starts the services defined in the `docker-compose.yaml` file |
| `docker compose down` | Stops and removes the running services |
| `docker compose logs` | Shows the logs of the services |
| `docker compose ps`   | Lists all the services and their current status |

Find the full list of commands [here](https://docs.docker.com/reference/cli/docker/compose/).

---

__Ex. 2.1.__

_Solution_

```yaml
services:
  simple-web-service:
    image: devopsdockeruh/simple-web-service
    volumes:
      - ./logs.log:/usr/src/app/text.log
    container_name: simple-web-service
```

---

Read [here](https://docs.docker.com/reference/compose-file/services/#command)) about how to add a command to docker compose. 
Also, read [here](https://docs.docker.com/compose/how-tos/environment-variables/set-environment-variables/) about how to add environment variables.

---

__Ex. 2.2.__

```yaml
services:
  web-server-compose:
    image: devopsdockeruh/simple-web-service
    ports:
      - 127.0.0.1:8080:8080
    command: server
    container_name: web-server-compose
```

---

---

__Ex. 2.3.__

I have decided to use the already built local images:

```yaml
services:
  frontend:
    image: project-frontend:latest
    ports:
      - 127.0.0.1:3000:3000
    container_name: frontend
  backend:
    image: project-backend:latest
    ports:
      - 127.0.0.1:8080:8080
    container_name: backend
```

---

### Docker networking

Docker compose starts and automatically joins the defined services into a [network with a DNS](https://docs.docker.com/engine/network/). The containers can then simply reference each other with their service names. 

---

__Ex. 2.4.__

```yaml
services:
  frontend:
    image: project-frontend:latest
    ports:
      - 127.0.0.1:3000:3000
    container_name: frontend-container
  backend:
    image: project-backend:latest
    ports:
      - 127.0.0.1:8080:8080
    container_name: backend-container
    restart: unless-stopped
    environment:
      - REDIS_HOST=redis
  redis:
    image: redis:7.2-bookworm
    container_name: redis-container

```

---

#### Manual network definition

It is possible to define a network manually in a `docker compose` file, and to establish a connection
to an external network (a network defined in another `docker compose` file). 

```yaml
services:
  db:
    image: postgres:13.2-alpine
    networks:
      - database-network <em># Name in this Docker Compose file</em>

networks:
  database-network: # Name in this Docker Compose file
    name: database-network # Name that will be the actual name of the network
```

```yaml
services:
  db:
    image: backend-image
    networks:
      - database-network

networks:
  database-network:
    external:
      name: database-network # Must match the actual name of the network
```

#### Scaling

Docker compose has the ability to scale a service and create multiple instances. For example, let's say we have the following `docker compose`:

```yaml
services:
  whoami:
    image: jwilder/whoami
    # Leave the host port unspecified, otherwise all instances will try to connect to the same port;
    # when left unspecified, Docker will automatically choose a free port.
    ports:
      - 8000
```

Then we can run this: `docker compose up --scale whoami=3` to spin up three containers of the same service.
We can run `docker compose port --index 1 whoami 8000` (change index for the other two) to see what ports
the containers are running on. 

For this type of a scaled up service, one would often use a load balancer, e.g., [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy):

```yaml
services:
  whoami:
    image: jwilder/whoami
    environment:
        # Nginx-proxy needs to know where to route!
      - VIRTUAL_HOST=whoami.colasloth.com
  proxy:
    image: jwilder/nginx-proxy
    volumes:
      # docker.sock provides access to the Docker Engine API, which contains all the information about
      # running containers, their configs, and their metadata.
      - /var/run/docker.sock:/tmp/docker.sock:ro # ro stands for read-only
    ports:
      - 80:80
```

Also read about [colasloth.com](https://colasloth.github.io/) if you're interested. It is a clever developer tool 
that saves developers from editing their local `/etc/hosts file`. Instead, `colasloth.com` always points to localhost!
Another interesting thing to learn about is `docker.sock`: [here](https://lobster1234.github.io/2019/04/05/docker-socket-file-for-ipc/) is a good resource!

---

__Ex. 2.5.__

We have the following `docker compose`:

```yaml
services:
  calculator:
      image: devopsdockeruh/scaling-exercise-calculator
      ports:
        - 3000:3000
      container_name: calculator
  compute:
      image: devopsdockeruh/scaling-exercise-compute
      environment:
        - VIRTUAL_HOST=compute.localtest.me
  load-balancer:
      build: ./load-balancer
      image: load-balancer
      volumes: 
        - /var/run/docker.sock:/tmp/docker.sock:ro
      ports:
        - 80:80
      container_name: load-balancer
```

I scaled the `compute`service to two container instances and got it to pass the test:

```bash
docker compose up --scale compute=2
```

---

### Volumes in action

We have the following `docker compose` file:

```yaml
services:                                   # Start of services definition
  db:                                       # Name of the service
    image: postgres                         # Use official PostgreSQL image
    restart: unless-stopped                 # Restart container unless manually stopped
    environment:                            # Environment variables section
      POSTGRES_PASSWORD: example            # Set PostgreSQL root password
    container_name: db_redmine              # Explicitly name the container
    volumes:                                # Container's volume mappings
      - database:/var/lib/postgresql/data   # Map named volume 'database' to PostgreSQL data directory

volumes:                                    # Docker volumes declaration
  database:                                 # Declare a volume named 'database'
  # We could specify further options here, e.g., driver, driver_opts, etc.
```

If we used the Postgres image without a `volume` configuration, an anonymous volume would still be created because the image's Dockerfile has a [`VOLUME` instruction](https://github.com/docker-library/postgres/blob/master/Dockerfile-alpine.template), but ["wouldn't persist when the container is deleted and re-created."](https://github.com/docker-library/docs/blob/master/postgres/README.md#where-to-store-data)


We can now add Redmine and Adminer like so:

```yaml
services:
  db:
    image: postgres
    restart: unless-stopped
    environment:
      POSTGRES_PASSWORD: example
    container_name: db_redmine
    volumes:
      - database:/var/lib/postgresql/data
  redmine:
    image: redmine:5.1-alpine
    environment:
      - REDMINE_DB_POSTGRES=db
      - REDMINE_DB_PASSWORD=example
    ports:
      - 9999:3000
    volumes:
      - files:/usr/src/redmine/files
    depends_on:
      - db
  adminer:
    image: adminer:4
    restart: always
    environment:
      - ADMINER_DESIGN=galkaev
    ports:
      - 8083:8080

volumes:
  database:
  files:
```




### Useful resources

- https://hub.docker.com/
- https://docs.docker.com/
- https://github.com/docker-library
- 
