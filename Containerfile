# syntax=docker/dockerfile:1

ARG BASE
FROM ${BASE}

COPY packages.txt /tmp/packages.txt
RUN grep -v '^#' /tmp/packages.txt | grep . \
      | xargs dnf install -y --setopt=install_weak_deps=False \
 && dnf clean all \
 && rm -f /tmp/packages.txt

# Files under system/ are copied onto / as-is.
COPY system/ /
