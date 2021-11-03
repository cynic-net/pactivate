FROM debian:11
RUN apt-get update && apt-get install -y \
    curl python3 python3-distutils \
    vim-tiny                                    # for debugging
ADD pactivate cont-test /test/
