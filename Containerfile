# syntax=docker/dockerfile:1

# Fedora 44 COSMIC Atomic as a bootable OS image (bootc).
# BASE is supplied by `tars os build` from digests.txt, the pinned base digest.
# The layered packages are the names in packages.txt. They float: the build
# takes the repos' current versions, and `tars os build` records the result
# in manifest.txt.

ARG BASE
FROM ${BASE}

# C toolchain (gcc, mold, glibc headers) so rustup/cargo can link on the host.
COPY packages.txt /tmp/packages.txt
RUN grep -v '^#' /tmp/packages.txt | grep . \
      | xargs dnf install -y --setopt=install_weak_deps=False \
 && dnf clean all \
 && rm -f /tmp/packages.txt
