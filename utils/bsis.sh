#/bin/bash

set -ex

docker run -it --rm -v "$(pwd)/sis/:/data/" mario33881/bettersis
