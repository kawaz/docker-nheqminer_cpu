FROM ubuntu:16.04 AS BUILD
RUN apt-get update && apt-get install -y git cmake build-essential libboost-all-dev && apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR /build
RUN git clone --depth 1 https://github.com/nicehash/nheqminer.git && \
  cd nheqminer/cpu_xenoncat/asm_linux/ && chmod +x fasm && sh assemble.sh && cd ../../.. && \
  mkdir build && cd build && \
  cmake -DUSE_CUDA_DJEZO=OFF ../nheqminer && \
  make -j $(nproc) && \
  cp nheqminer /usr/bin/nheqminer_cpu && ln -s nheqminer_cpu /usr/bin/nheqminer && \
  ldd /usr/bin/nheqminer_cpu | grep -Eo '/[^ ]+' > /build/nheqminer_cpu.dep_ldd && \
  dpkg -S $(cat /build/nheqminer_cpu.dep_ldd) | perl -pe's/:.*//' | sort -u > /build/nheqminer_cpu.dep_packages

FROM ubuntu:16.04
COPY --from=BUILD /usr/bin/nheqminer_cpu /usr/bin/nheqminer /usr/bin/
COPY --from=BUILD /build/nheqminer_cpu.dep_packages /
RUN apt-get update && apt-get install -y $(cat /nheqminer_cpu.dep_packages) --no-install-recommends && rm -f /nheqminer_cpu.dep_packages && \
  apt-get clean && rm -rf /var/lib/apt/lists/*
ENV \
  SERVER=equihash.jp.nicehash.com:3357 \
  WALLET=361yTPdoXcBpWRJDpPJSoC2v5Ss3fYM3FL \
  WORKER=
ENTRYPOINT [ "bash", "-c", "if [[ $# == 0 ]]; then set -- -l \"$SERVER\" -u \"$WALLET.${WORKER:-$HOSTNAME}\"; fi; exec nice -n 17 nheqminer_cpu \"$@\"", "--" ]
