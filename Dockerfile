FROM alpine:latest as build
RUN mkdir -p /opt
RUN apk --no-cache add build-base libusb-dev curl
WORKDIR /build
RUN curl https://svwh.dl.sourceforge.net/project/openocd/openocd/0.10.0/openocd-0.10.0.tar.bz2 -o openocd.bz2
RUN tar -xjvf openocd.bz2
WORKDIR /build/openocd-0.10.0
RUN ./configure --enable-stlink --prefix /build/openocd
RUN make -j 4 && make install
WORKDIR /build
RUN curl https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/7-2017q4/gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2 -o toolchain.bz2
RUN tar xjvf toolchain.bz2 

FROM frolvlad/alpine-glibc as final
COPY --from=build /build/openocd /opt/openocd
COPY --from=build /build/gcc-arm-none-eabi-7-2017-q4-major /opt/toolchain
RUN apk --no-cache add cmake make libusb 
ENV PATH="/opt/toolchain/bin:/opt/openocd/bin:${PATH}"
RUN ls -1 /opt/toolchain/bin | sed -r "s|(arm-none-eabi-)(.*)|ln -s /opt/toolchain/bin/\1\2 /usr/local/bin/\2|g" | sh

# COPY nucleo-f767zi.cfg /opt/openocd/share/openocd/scripts/board/st_nucleo_f7.cfg

EXPOSE 3333 4444 6666