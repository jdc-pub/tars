# tars

Fedora 44 COSMIC Atomic as a bootable container image (`bootc`).

The `Containerfile` is built from *other images only* — no `dnf`, no scripts — so every input is a pinned digest and builds are reproducible.

## Use

Needs `make`, `podman`, `skopeo` and `sudo`. Run from the host (or a toolbox with `make`).

```sh
make              # list targets
make digests      # refresh the base pin in digests.txt
make build        # build into root's container storage
make deploy       # switch this machine over (reboot to apply)
```

Install stock Fedora COSMIC Atomic from the official ISO first, then `make deploy`. Roll back with `bootc rollback` or the boot menu.

## Notes

- **`digests.txt` is the single source of truth** for the base pin; `make build` passes it to the `Containerfile`. It is generated, so don't hand-edit it. Keep it in Git so bumps show up in review.
- **Local storage for now.** `bootc upgrade` does nothing for a local image, so update by re-running `make build deploy`. When this moves to GitHub, set `IMAGE=ghcr.io/<user>/tars:44`, build and push from Actions, and `bootc switch` to it for normal `bootc upgrade`.
- **Pins expire.** Fedora's dated tags are removed after about 4 weeks, so run `make digests` before each build.
- **Adding content means adding an image.** Use `COPY --from=<pinned image>`.
- Kernel build tooling lives in toolbox, not in this image.
