fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build + upload a build to TestFlight

### ios beta_external

```sh
[bundle exec] fastlane ios beta_external
```

Build + upload + submit to Beta App Review for external testing (public link)

### ios release

```sh
[bundle exec] fastlane ios release
```

Build + upload binary and metadata to App Store; submit for review

### ios metadata

```sh
[bundle exec] fastlane ios metadata
```

Push text metadata only (no binary, no screenshots)

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Upload screenshots only (drop PNGs in fastlane/screenshots/<locale>/)

### ios build

```sh
[bundle exec] fastlane ios build
```

Build a signed .ipa locally (no upload)

### ios bump

```sh
[bundle exec] fastlane ios bump
```

Set CFBundleVersion to (latest TestFlight build + 1)

### ios register

```sh
[bundle exec] fastlane ios register
```

Register app IDs / sync signing certificates & profiles (match)

### ios dsyms

```sh
[bundle exec] fastlane ios dsyms
```

Download dSYMs from App Store Connect for crash symbolication

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
