# tars

Fedora 44 COSMIC Atomic as a bootable container image, built with `bootc` from a plain `Containerfile`. Run on the host, not in a container. Has `podman`, `skopeo`, `bootc` and `sudo` from stock Atomic.

## Layout

| Path | What it holds |
| --- | --- |
| `Containerfile` | One pinned input (the base image) and one floating one (the layered packages). No third-party code in the build. |
| `digests.txt` | The pinned base image digest, written by `tars os bump`. Do not hand-edit. |
| `packages.txt` | Layered RPM names, hand-edited, one per line. They float. |
| `system/` | Overlay copied onto `/` in the image (`COPY system/ /`). Path under `system/` is the path in the image. Holds config such as `usr/lib/NetworkManager/conf.d/30-wifi-powersave.conf`. |
| `system/etc/yum.repos.d/rex.repo` | Rex package repo (preview channel; no stable release yet). Copied before the dnf step in the `Containerfile`, so `rex` in `packages.txt` resolves. Switch channel by editing `name` and `baseurl`. The Fedora package `Rex` (Perl) conflicts with it; `system/etc/dnf/libdnf5.conf.d/50-tars-exclude-perl-rex.conf` excludes it so dnf cannot install it. |
| `system/usr/libexec/tars/sensor-log` | Stdlib-Python sensor logger run by `tars-sensor-log.service` (enabled in the `Containerfile`). Writes `/var/log/tars/sensors.log`, fsynced, last 1000-2000 samples, previous three boots kept as `sensors.N.log`. Read `sensors.1.log` after a crash. |
| `manifest.txt` | Every RPM in the built image with its exact version, written by `tars os build`. A record, never an input. Commit it so `git diff` shows what an update changed. |
| `bin/tars` | Dispatcher. `tars <cmd>` runs the `tars-<cmd>` script beside it. |
| `bin/tars-os` | Image management (bump, build, deploy, update, status). |
| `bin/tars-git` | Runs git in this repo from any directory. |
| `bin/tars-verify` | Checks `packages.txt` and `manifest.txt` against the running system: every entry is in the manifest and installed, and the manifest equals the installed RPMs. Exits 1 on any mismatch. |

## Build and update

`tars os build` reads the base pin, then builds with `--pull=missing --no-cache` into root's container storage. Root storage because bootc reads root's containers-storage. The base is pinned by digest, so a local copy is exact and only a missing one is pulled. No cache because the dnf layer's inputs do not change when the repos do, so a cached layer would keep old versions. The dnf step still has a `--mount=type=cache` on `/var/cache/libdnf5` so unchanged RPMs are not downloaded again; it runs with `--refresh` so metadata is never reused and floating packages still update. It then writes `manifest.txt` from `rpm -qa` of the built image, shows what changed since the last commit in the three tracked files, and offers to commit just them. A floating package can pull a newer version of a package the base ships (for example `glibc-devel` needing a matching `glibc`); build warns when that happens.

`tars verify` compares the repo with what is installed. After `tars os build` it reports a mismatch until the new image is deployed and booted; that is expected.

`tars os bump` moves the base pin and shows the change but does not offer to commit, since a new digest with the old manifest is a state that was never built.

The base digest is the reproducibility anchor, together with the built image and `bootc rollback`. Exact RPM versions are not pinned by default: Fedora keeps only the latest build of each package, so such pins go stale within days. To hold one, write its full spec (`gcc-16.2.1-2.fc44`) in `packages.txt`.

Fedora's dated tags are removed after about four weeks, so an old digest will eventually fail to pull. Run `tars os bump` or `tars os update` at least that often.

`tars os deploy` runs `bootc upgrade`, which follows the image the machine is already on. The one-off move onto the image is `bootc switch`. Switching to the image you are already on is a no-op even if the image behind the name changed. To move to a registry, set `TARS_IMAGE=ghcr.io/<user>/tars:44`, build and push from Actions, and `bootc switch` to it once.

BlueBuild was tried and dropped. It pulled third-party images by tag that run as root and ship in the OS, and its scripts rewire `/opt`, wipe `/var` and rewrite rpm-ostree's base record. The plain `Containerfile` does none of that. Prefer `COPY --from=<pinned image>` over a module for anything that is not a system toolchain.

Rust lives in `~/.rustup`, pinned per project with `rust-toolchain.toml` and linked with mold via `~/.cargo/config.toml`. Kernel build tooling lives in toolbox, not in this image.

Update this file when the information in it changes during a task.
