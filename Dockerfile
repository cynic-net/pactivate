FROM debian:11
RUN apt-get -qq update && apt-get install -y -qq \
    curl python3 python3-distutils \
    vim-tiny                                    # for debugging
ADD pactivate cont-test /test/
