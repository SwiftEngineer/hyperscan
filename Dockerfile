FROM amazonlinux:latest AS build

# INSTALL BASE C LIBS

# get dev tools
RUN yum -y groupinstall "Development Tools"

# install cmake to build shit and wget because we're gonna need it to fetch 
# a lot of additional dependencies.
RUN yum install -y cmake wget

# INSTALL BOOST

RUN mkdir /boost

WORKDIR /boost

RUN wget https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.gz

RUN tar -xvf boost_1_65_1.tar.gz

ENV "BOOST_INCLUDEDIR" "/boost/boost_1_65_1"
ENV "BOOST_ROOT" "/boost/boost_1_65_1"
ENV "BOOST_LIBRARYDIR" "/boost/boost_1_65_1/stage/lib"

# INSTALL RAGEL

RUN mkdir /ragel

WORKDIR /ragel

RUN wget http://www.colm.net/files/ragel/ragel-6.10.tar.gz

RUN tar -xvf ragel-6.10.tar.gz

WORKDIR /ragel/ragel-6.10

RUN ./configure
RUN make
RUN make install

# BUILD HYPERSCAN

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
RUN g++ -fpic -shared -static-libstdc++ -Wl,--whole-archive libchimera.a libhs.a libpcre.a -Wl,--no-whole-archive -static-libstdc++ -o libchimera.so