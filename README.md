# CircleCI multi-file config

A sane workflow for managing large circleci configurations.

## What is it?

This repo contains a Makefile in `copythis.circleci/`
which you can copy to your own project's `.circleci/`
directory. The Makefile's main target `make ci-config`
generates a single 2.0 syntax `.circleci/config.yml`
from the yml file tree in `.circleci/config/` in 2.0 or 2.1 syntax.

### What does each file do?

```
├── README.md                # This file.
├── copythis.circleci        # Dir containing stuff to copy.
│   ├── .gitattributes       # This file tells GitHub not to show diffs for the generated config.yml
│   ├── .gitignore           # This file tells git to ignore temp files.
│   ├── Makefile             # This is the main file defining the workflow.
│   ├── README.md            # The usage README. You should copy this into your .circleci dir too!
│   ├── pre-commit           # Git pre-commit hook. Highly recommended to use this.
│   └── config.make.sample   # It's slightly configurable! (Probably needless complexity.)
```

## Installation

Copy everything (including dotfiles) in `copythis.circleci` to your own project's
`.circleci` directory. Copy the git `pre-commit` hook file to that
project's `.git/hooks` directory, so you don't shoot yourself in the foot.

Once that is done, see the [usage README] in that directory.

It is usually safe to perform this installation
even if you already have a `.circleci/config.yml`
and you can begin breaking up the config into separate
files under the `.circleci/config` directory, as you see fit.

This is all supported by the circleci-cli tool anyway,
but the Makefile and git hook make it much more convenient to use.

Much more detail on usage and syntax in the [usage README].

[usage README]: copythis.circleci/README.md


