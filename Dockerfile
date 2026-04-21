# syntax=docker/dockerfile:1.19

# -------- Builder stage --------
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    ninja-build \
    git \
    curl \
    pkg-config \
    python3 \
    zstd \
    libgmp-dev \
    python3-venv \
    libtool \
    libz-dev \
    libboost-all-dev \
    libmpfr-dev \
    libbz2-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN git clone https://github.com/TendTo/qsopt-ex.git --depth 1 \
    && cd /src/qsopt-ex \
    && ./bootstrap \
    && mkdir build && cd build \
    && ../configure --disable-debug CFLAGS='-O3' \
    && make -j"$(nproc)" \
    && make install

RUN git clone https://github.com/scipopt/soplex.git --depth 1 \
    && cd /src/soplex \
    && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DGMP=ON -DMPFR=ON -DBOOST=ON -DZLIB=OFF \
    && cd build \
    && make -j"$(nproc)" libsoplex \
    && make install

RUN sed -i -re 's/\.so([^.])/\.a\1/g' /usr/local/lib/cmake/soplex/soplex-targets.cmake \
    && sed -i -re 's/\.so([^.])/\.a\1/g' /usr/local/lib/cmake/soplex/soplex-targets-release.cmake

WORKDIR /src/cvc5

COPY . /src/cvc5

# Configure and build cvc5 as a static binary.
RUN cmake -S . -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Production \
    -DBUILD_SHARED_LIBS=OFF \
    -DSTATIC_BINARY=ON \
    -DENABLE_UNIT_TESTING=OFF \
    -DBUILD_DOCS=OFF \
    -DBUILD_BINDINGS_PYTHON=OFF \
    -DBUILD_BINDINGS_JAVA=OFF \
    -DUSE_SOPLEX:BOOL=ON \
    -DUSE_GLPK:BOOL=ON \
    -DENABLE_AUTO_DOWNLOAD=ON \
    -DENABLE_GPL:BOOL=ON \
    -DUSE_QSOPTEX:BOOL=ON \
    && cmake --build build --target cvc5-bin -j"$(nproc)"

ENTRYPOINT ["/bin/bash"]

# -------- Runtime stage --------
FROM quay.io/jupyter/scipy-notebook AS runtime

ENV DEBIAN_FRONTEND=noninteractive


# Use root to create the /benchmarks directory and set permissions, as the default user in the base image does not have permissions to create directories in the root filesystem.
USER root
RUN mkdir -p /benchmarks && \
    chmod -R a+rwX /benchmarks
USER $NB_USER


# Fetch and unpack SMT-LIB QF_LRA benchmark archive, moving them all to the /benchmarks directory.
RUN curl -L "https://zenodo.org/records/16740866/files/QF_LRA.tar.zst?download=1" \
    -o /tmp/QF_LRA.tar.zst \
    && tar --zstd -xf /tmp/QF_LRA.tar.zst -C /benchmarks \
    && rm -f /tmp/QF_LRA.tar.zst && \
    find /benchmarks -type f -name "*.smt2" -exec mv {} /benchmarks/ \; && \
    find /benchmarks -type d -empty -delete


ADD https://objectstorage.eu-zurich-1.oraclecloud.com/p/xlfE6Ysf_O7Eey_sTiBu_tTUTt7dJhTFjq0rSJJkf4Rz4YgvFxa0i1PzFNj-Vwyn/n/zrr1s09jjqfi/b/dlinear/o/sk.tar.xz /benchmarks

WORKDIR /work

RUN touch .dockerenv


COPY --from=builder --chown=$NB_USER --chmod=777 /src/cvc5/build/bin/cvc5 /usr/local/bin/cvc5

COPY --chown=$NB_USER benchmarks .

COPY --chown=$NB_USER artifact/scripts .
