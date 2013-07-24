fip-notifier
============

Because the internet stream for FIP (http://www.fipradio.fr) doesn't display
artist information.

You will need:

* the `libnotify-bin` package (at least that's what it's called in Debian) for
  the `notify-send` program
* a properly-configured OPAM with the following packages: yojson, ocurl.

Just hit `make` then `./fip.native`.
