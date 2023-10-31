ARG DISTRO
FROM $DISTRO
ARG DISTRO                      # previous ARGs wiped out by FROM

#   This can be used in a container to find the FROM line its image was built
#   with. We do not use an environment variable because that's too easy to
#   override when running the container.
RUN echo $DISTRO >/DISTRO

#   Through this section we have the minimal setup for the package installs to
#   avoid regenerating this more often that we need to (it can take some time).
ADD tscript/docker-data/pkg-inst /test/
RUN /test/pkg-inst "$DISTRO"

#   Suppress messages from Pip about how running as root is a bad idea,
#   since it's not a bad idea inside a Docker container.
ENV PIP_ROOT_USER_ACTION=ignore

ADD tscript/docker-data/bashrc /root/.bashrc
ADD tscript/docker-data/bash_profile /root/.bash_profile
ADD pactivate tscript/docker-data/cont-test /test/
