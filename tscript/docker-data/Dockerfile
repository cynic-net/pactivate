ARG DISTRO
FROM $DISTRO
ARG DISTRO                      # previous ARGs wiped out by FROM

#   This can be used in a container to find the FROM line its image was built
#   with. We do not use an environment variable because that's too easy to
#   override when running the container.
RUN echo $DISTRO >/DISTRO

RUN apt-get -qq update && apt-get install -y -qq \
    curl python3 python2 \
    vim-tiny                                    # for debugging
    #   Note no python3-distutils here! We test error message when not present.

#   Suppress messages from Pip about how running as root is a bad idea,
#   since it's not a bad idea inside a Docker container.
ENV PIP_ROOT_USER_ACTION=ignore

ADD tscript/docker-data/bashrc /root/.bashrc
ADD pactivate tscript/docker-data/cont-test /test/
