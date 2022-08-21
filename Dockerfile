FROM ubuntu:jammy

# based on https://github.com/stefda/docker-osmium-tool
ENV DEBIAN_FRONTEND noninteractive

ENV OSMIUM_VERSION 2.18.0
ENV OSMIUM_TOOL_VERSION 1.14.0

RUN apt-get update && apt-get updrade
RUN apt-get update && apt-get install -y \
    cmake cmake-curses-gui doxygen g++ graphviz libboost-dev libboost-program-options-dev \
    libbz2-dev libexpat1-dev libgdal-dev libgdal-doc libgeos-c1v5 libgeos-dev libgeos3.10.2 \
    liblz4-dev libosmium2-dev libproj-dev libprotozero-dev libsparsehash-dev make pandoc \
    rapidjson-dev wget zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /var/install
WORKDIR /var/install

RUN wget https://github.com/osmcode/libosmium/archive/v${OSMIUM_VERSION}.tar.gz && \
    tar xzvf v${OSMIUM_VERSION}.tar.gz && \
    rm v${OSMIUM_VERSION}.tar.gz && \
    mv libosmium-${OSMIUM_VERSION} libosmium

RUN cd libosmium && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=ON -DINSTALL_PROTOZERO=ON .. && \
    make

RUN wget https://github.com/osmcode/osmium-tool/archive/v${OSMIUM_TOOL_VERSION}.tar.gz && \
    tar xzvf v${OSMIUM_TOOL_VERSION}.tar.gz && \
    rm v${OSMIUM_TOOL_VERSION}.tar.gz && \
    mv osmium-tool-${OSMIUM_TOOL_VERSION} osmium-tool

RUN cd osmium-tool && \
    mkdir build && cd build && \
    cmake -DOSMIUM_INCLUDE_DIR=/var/install/libosmium/include/ .. && \
    make

RUN mv /var/install/osmium-tool/build/src/osmium /usr/bin/osmium


ENTRYPOINT ["/usr/bin/osmium"]

CMD ["/usr/bin/osmium", "-h"]
