FROM debian:11
RUN apt-get update && apt-get install -y curl python3 python3-distutils
ADD pactivate cont-test /test/
