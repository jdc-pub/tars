# syntax=docker/dockerfile:1

ARG BASE
FROM ${BASE}

# Repo definitions and dnf config must exist before the install below.
COPY system/etc/yum.repos.d/ /etc/yum.repos.d/
COPY system/etc/dnf/ /etc/dnf/

COPY packages.txt /tmp/packages.txt
# The cache mount keeps downloaded RPMs between builds and stays out of the
# image, so there is no "dnf clean all". --refresh re-fetches repo metadata
# every build; without it the kept metadata would hide new versions.
RUN --mount=type=cache,target=/var/cache/libdnf5,sharing=locked \
    grep -v '^#' /tmp/packages.txt | grep . \
      | xargs dnf install -y --refresh --setopt=install_weak_deps=False \
          --setopt=keepcache=1 \
 && rm -f /tmp/packages.txt

# Files under system/ are copied onto / as-is.
COPY system/ /

RUN systemctl enable tars-sensor-log.service
