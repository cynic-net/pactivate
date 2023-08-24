FROM debian:11
RUN apt-get -qq update && apt-get install -y -qq \
    curl python3 python2 \
    vim-tiny                                    # for debugging
    #   Note no python3-distutils here! We test error message when not present.

#   Suppress messages from Pip about how running as root is a bad idea,
#   since it's not a bad idea inside a Docker container.
ENV PIP_ROOT_USER_ACTION=ignore

ADD bashrc /root/.bashrc
ADD pactivate tscript/cont-test /test/
