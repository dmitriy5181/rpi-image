FROM debian:buster-slim AS build

RUN apt-get update && apt-get install --yes \
    libguestfs-tools wget unzip qemu-user-static

WORKDIR /buildarea

RUN wget --quiet https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2020-02-14/2020-02-13-raspbian-buster-lite.zip
RUN unzip *.zip
RUN mkdir rootfs && guestfish --ro --add *.img --mount /dev/sda2 copy-out / rootfs

# see https://www.raspberrypi.org/forums/viewtopic.php?t=235594
RUN sed -i 's/\${PLATFORM}/v6l/' rootfs/etc/ld.so.preload

FROM scratch

COPY --from=build /buildarea/rootfs /
COPY --from=build /usr/bin/qemu-arm-static /usr/bin/
CMD ["bash"]