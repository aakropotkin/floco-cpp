# floco-cpp

This library contains C++ utilities for use in the
[floco](https://github.com/aakropotkin/floco) framework.

Currently this project is in early stages and is not in use by `floco`.

## Goals
- [x] Create a cached database for NPM registry fetches.
- [ ] Migrate basic ~floco translate~ routines to C++.
  + [ ] resolve, fetch, and translate descriptors.
    - [x] Use `semver` with `Packument` to _resolve_ descriptors.
          [registry.cc](./src/npm/registry.cc)
- [ ] translate `pdefs' recursively.
- [ ] Create a cached database for translated package metadata.
      Cache metadata AS IS from `floco translate` without `foverrides` patches.
- [ ] Create a cached database for source tree hashes.
- [ ] Translate recursively for projects with `install` scripts.
- [ ] Cache `semver` range checking, or port `semverSat` to C++.
- [ ] Support workspaces.
- [ ] Migrate _ideal tree_ formation routines to C++.
- [ ] Migrate `checkSystemSupport` routine to C++.
  + [ ] Handle "!*" values.
- [ ] Create an interactive tree editor.
      A library such as `fzf`, `ranger`, or `ncurses` is a useful base.

## Documentation
Docs are generated automatically by `make docs` and can be read
[here](aakropotkin.github.io/floco-cpp/index.html).
