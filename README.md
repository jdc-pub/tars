# tars

Fedora 44 COSMIC Atomic as a bootable container image (`bootc`).

The `Containerfile` has two pinned inputs, so builds are reproducible: the base image digest (`digests.txt`) and an exact list of RPMs (`packages.txt`). The one `dnf install` in it only installs those exact versions.

## Use

Run on the host. Needs `podman`, `skopeo`, `bootc` and `sudo` (all on Atomic already). Optionally `ln -s "$PWD/tars" ~/.local/bin/tars`.

```sh
./tars                # list commands
./tars os             # list OS subcommands
./tars os digests     # refresh the base pin (digests.txt) and RPM pins (packages.txt)
./tars os digests --no-base   # keep the base pin, only re-resolve the RPMs
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
- **`packages.txt` is generated too.** `tars os digests` resolves the full dependency closure of the `want` list in `bin/tars-os` (currently `gcc mold`) inside the pinned base image and records exact versions. To add a package, add it to `want` and run `tars os digests --no-base`, which leaves the base pin alone. Both files are written only after everything succeeds. Review the diff.
- **RPM pins expire.** Fedora only keeps the latest build of each package, so an old `packages.txt` will fail to build once those versions are replaced. That is deliberate: re-run `tars os digests` and review.
- **Everything else should be an image.** Prefer `COPY --from=<pinned image>` for content that isn't a system toolchain.
- **Rust itself lives in `~/.rustup`**, pinned per project with `rust-toolchain.toml`. Link with mold via `~/.cargo/config.toml`.
- Kernel build tooling lives in toolbox, not in this image.
