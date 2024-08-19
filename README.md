# GitHub Action check_localization_php


## Usage

Use with [GitHub Actions](https://github.com/features/actions)

_.github/workflows/check_localization_php.yml_

```
name: check_localization_php
on: pull_request
jobs:
  check_localization_php:
    runs-on: ubuntu-latest
    steps:
        - uses: actions/checkout@v1
        - uses: fxpw/check_localization_php@main
```

