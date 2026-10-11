# sqlite3-static

Portable builds of the [sqlite3](https://sqlite.org/cli.html) shell of [SQLite](https://sqlite.org/), with the
library and the common extensions (FTS3/4/5, R-Tree, GeoPoly, session, dbstat) built in and
[linenoise](https://github.com/antirez/linenoise) for line editing, built with [zig](https://ziglang.org) as the C toolchain.

- Linux glibc: only glibc is linked dynamically, and only symbols up to glibc 2.17, so the
  binaries run on anything from CentOS 7 onwards
- Linux musl (`--static`): fully static, no runtime dependencies at all (e.g. Alpine)
- macOS: only libSystem is dynamic (it ships with macOS, which has no fully static binaries)

Loading extensions at runtime is disabled in the fully static build, which cannot `dlopen`; the
builds for glibc and macOS can.

## Prerequisites

- `zig`, GNU make (the `make` 3.81 of macOS is enough), `git`, `tclsh` (to generate the amalgamation)

## Installation

Clone the repo with submodules (shallow, the history of the vendored projects is not needed):

```shell
git clone --recurse-submodules --shallow-submodules https://github.com/zshsetup/sqlite3-static
cd sqlite3-static
```

## Usage

```shell
./build.sh
```

Output is installed under `dist/`:

- `dist/bin/sqlite3`: the shell, with the library inside; copy it anywhere on your `PATH`
- `dist/share/man/man1/sqlite3.1`: the man page

Pass `--static` for the fully static musl build on Linux (output in `dist-static/`), `--clean` to
remove previous build output first, and `--jobs N` to control parallelism.

To run the smoke tests against the build:

```shell
./tests/run_smoke_tests.sh            # dist/
./tests/run_smoke_tests.sh --static   # dist-static/
```

## Releases

Publishing a GitHub release tagged like the contents of `VERSION`, the tag checked out in
`vendor/sqlite`, builds and attaches `sqlite3-static-<platform>.tar.gz` for `macos-arm64`,
`linux-amd64`, `linux-arm64`, `linux-musl-amd64`, and `linux-musl-arm64`, together with the sources
they were built from (`sqlite3-static-sources.tar.gz`).

To update a vendored project, check out a new release tag in its submodule, commit it, and update
`VERSION` if it is the main one, e.g.
`git -C vendor/sqlite fetch --depth 1 origin tag version-3.53.4 && git -C vendor/sqlite checkout version-3.53.4`.

## Acknowledgments

This repository builds and vendors the following upstream projects, unmodified, as git
submodules under `vendor/`. Credit goes to their respective authors:

- [SQLite](https://github.com/sqlite/sqlite) by D. Richard Hipp and contributors
- [linenoise](https://github.com/antirez/linenoise) by Salvatore Sanfilippo and Pieter Noordhuis

## License

MIT for the code in this repository. See `NOTICE` for the licenses of the upstream projects and the
resulting binaries, which are public domain (SQLite) and BSD-2-Clause (linenoise).
