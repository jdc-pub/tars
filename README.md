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

## Sensor log

`tars-sensor-log.service` (enabled in the image) writes one line every 2 s to `/var/log/tars/sensors.log`: every hwmon temperature, fan, power and voltage reading, CPU busy %, peak clock, and the busiest process when the CPU is over 20% busy. Each line is `fsync`ed, so a hard power cut or thermal trip loses at most one sample. The file holds between 1000 and 2000 of the latest samples (33 to 66 min), because it trims in batches, and the previous three boots are kept as `sensors.1.log` to `sensors.3.log`. After a crash, read the end of `sensors.1.log`.

Source: `system/usr/libexec/tars/sensor-log`. Tune with `TARS_SENSOR_INTERVAL` and `TARS_SENSOR_KEEP` in the unit.
