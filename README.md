# tars

Fedora 44 COSMIC Atomic as a bootable container image (`bootc`).

The `Containerfile` is built from *other images only* — no `dnf`, no scripts — so every input is a pinned digest and builds are reproducible.

## Use

Run on the host. Needs `podman`, `skopeo`, `bootc` and `sudo` (all on Atomic already). Optionally `ln -s "$PWD/tars" ~/.local/bin/tars`.

```sh
./tars                # list commands
./tars os             # list OS subcommands
./tars os digests     # refresh the base pin in digests.txt
./tars os build       # build into root's container storage
./tars os deploy      # switch this machine over (reboot to apply)
./tars os status      # show deployments
```

`./tars git <args>` runs git in this repo from anywhere.

`tars` dispatches `tars <cmd>` to the `tars-<cmd>` script beside it, so new areas are new `tars-*` files.

Install stock Fedora COSMIC Atomic from the official ISO first, then `tars os deploy`. Roll back with `bootc rollback` or the boot menu.

## Notes

- **`digests.txt` is the single source of truth** for the base pin; `tars os build` passes it to the `Containerfile`. It is generated, so don't hand-edit it. Keep it in Git so bumps show up in review.
- **Local storage for now.** `bootc upgrade` does nothing for a local image, so update by re-running `tars os build` and `tars os deploy`. When this moves to GitHub, set `TARS_IMAGE=ghcr.io/<user>/tars:44`, build and push from Actions, and `bootc switch` to it for normal `bootc upgrade`.
- **Pins expire.** Fedora's dated tags are removed after about 4 weeks, so run `tars os digests` before each build.
- **Adding content means adding an image.** Use `COPY --from=<pinned image>`.
- Kernel build tooling lives in toolbox, not in this image.
