# tars

Fedora 44 COSMIC Atomic as a bootable container image (`bootc`).

## Use

Run on the host. Needs `podman`, `skopeo`, `bootc` and `sudo`. Optionally `ln -s "$PWD/bin/tars" ~/.local/bin/tars`.

```sh
bin/tars              # list commands
bin/tars os           # list OS subcommands
bin/tars os bump      # move the base pin to the current digest of the tag
bin/tars os build     # build into root's container storage, write manifest.txt, offer to commit
bin/tars os deploy    # stage the rebuilt image (bootc upgrade; reboot to apply)
bin/tars os update    # bump + build, then offer to deploy
bin/tars os status    # show deployments
```

`tars git <args>` runs git in this repo from anywhere.

`tars` dispatches `tars <cmd>` to the `tars-<cmd>` script beside it, so new areas are new `tars-*` files.

Install stock Fedora COSMIC Atomic from the official ISO first. Then, once per install, move onto the image:

```sh
bin/tars os build
sudo bootc switch --transport containers-storage localhost/tars:44
```

Reboot. From then on, update with `tars os update` and reboot. Roll back with `bootc rollback` or the boot menu.
