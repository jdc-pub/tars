# syntax=docker/dockerfile:1

# Fedora 44 COSMIC Atomic as a bootable OS image (bootc).
# Composed from other images only: no dnf, no scripts.
# BASE is supplied by `make build` from digests.txt (the single source of truth).

ARG BASE
FROM ${BASE}
