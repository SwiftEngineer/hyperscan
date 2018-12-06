FROM gcc:7 AS build

# fetch dependencies for building hyperscan and chimera
RUN apt-get update && apt-get install -y --no-install-recommends \
  cmake \
  zlib1g-dev libbz2-dev libsnappy-dev \
  libboost-all-dev \
  ragel \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# copy code into container
COPY . /hyperscan

# make directory to build hyperscan in
RUN mkdir /build-hyperscan

WORKDIR /build-hyperscan

# configure hyperscan
RUN cmake -DBUILD_STATIC_AND_SHARED=YES -DCMAKE_BUILD_TYPE=MinSizeRel /hyperscan

# build hyperscan
RUN cmake --build .

WORKDIR /build-hyperscan/lib

# combine static archives into single lib
RUN g++ -fpic -shared -Wl,--whole-archive libchimera.a libhs.a libpcre.a -Wl,--no-whole-archive -o libchimera.so