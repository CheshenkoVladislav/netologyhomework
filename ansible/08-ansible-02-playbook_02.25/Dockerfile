FROM fedora:rawhide

SHELL [ "/bin/bash", "-c" ]

RUN dnf install python3 -y && \
    dnf -y install systemd dbus && dnf clean all &&\
    dnf install -y python3-pip && \
    pip3 install requests