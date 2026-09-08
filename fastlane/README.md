# Release automation

App Store Connect metadata + [fastlane](https://fastlane.tools) lanes for building,
signing, and shipping, versioned alongside the app.

## One-time setup

1. Install tooling:
   ```bash
   brew install xcodegen
   bundle install
   ```
2. Create an **App Store Connect API key**: App Store Connect → Users and Access →
   Integrations → App Store Connect API → generate a key with *App Manager* role.
   Download the `.p8` (you only get one chance).
3. Configure secrets:
   ```bash
   cp fastlane/.env.default fastlane/.env
   # put the .p8 somewhere in the repo (it's gitignored), e.g. fastlane/AuthKey.p8
   # fill ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH in fastlane/.env
   ```
4. Create the app record in App Store Connect once (bundle id
   `com.andrew4coding.moneylaundering.Money-Laundering`), or run `bundle exec fastlane produce`.

### Code signing

- **Automatic (default):** nothing to configure — `build` uses `-allowProvisioningUpdates`
  and Xcode manages certs/profiles for team `92QV2QPDKA`.
- **`match` (recommended for CI / multiple machines):** create a private git repo for
  certificates, then set `MATCH_GIT_URL` and `MATCH_PASSWORD` in `fastlane/.env` and run
  `bundle exec fastlane ios register`.

## Lanes

| Command | What it does |
|---|---|
| `bundle exec fastlane ios beta` | regenerate project → bump build number → build → upload to TestFlight (internal). Add `wait:true` to block on processing. |
| `bundle exec fastlane ios release` | regenerate → precheck → bump → build → upload binary + metadata. Add `submit:true` to submit for review, `force:true` to skip the metadata-preview prompt. |
| `bundle exec fastlane ios metadata` | push `metadata/` text only — no build. Safe to run anytime. |
| `bundle exec fastlane ios screenshots` | upload PNGs from `screenshots/<locale>/` — no build. |
| `bundle exec fastlane ios build` | produce a signed `build/fastlane/MoneyLaundering.ipa` locally, no upload. |
| `bundle exec fastlane ios bump` | set `CURRENT_PROJECT_VERSION` in `project.yml` to (latest TestFlight build + 1). |
| `bundle exec fastlane ios register` | register app IDs and sync signing via `match`. |
| `bundle exec fastlane ios dsyms` | download dSYMs for the current marketing version. |

Version numbers live in `project.yml` (`MARKETING_VERSION`, `CURRENT_PROJECT_VERSION`).
Bump `MARKETING_VERSION` by hand for a new user-facing version; `bump` handles the build number.

## Metadata layout

- `metadata/en-US/` — localized listing text. Files marked `TODO:` must be filled before submit.
- `metadata/copyright.txt`, `primary_category.txt` — non-localized listing fields.
- `metadata/review_information/` — App Review contact + demo account. `demo_user`/`demo_password`
  are intentionally empty: the app has a local-only mode, so no login is required to review.
- `screenshots/en-US/` — real device screenshots (6.9" iPhone required; others optional).

## Before first submission

- [ ] `brew install xcodegen && bundle install`, then `fastlane/.env` filled.
- [ ] Fill every `TODO:` file under `metadata/`.
- [ ] Host and verify the **privacy policy URL** and **support URL** (must not 404).
- [ ] Add screenshots that match the shipped UI.
- [ ] Set age rating in App Store Connect (Finance, no objectionable content).
- [ ] Complete the App Privacy questionnaire so it matches `Money Laundering/PrivacyInfo.xcprivacy`
      (Name — linked to identity, not tracking; nothing else collected).
- [ ] `bundle exec fastlane ios beta` and smoke-test via TestFlight.
- [ ] `bundle exec fastlane ios release submit:true`.

## CI (GitHub Actions sketch)

```yaml
- uses: ruby/setup-ruby@v1
  with: { bundler-cache: true }
- run: brew install xcodegen
- run: bundle exec fastlane ios beta
  env:
    ASC_KEY_ID:      ${{ secrets.ASC_KEY_ID }}
    ASC_ISSUER_ID:   ${{ secrets.ASC_ISSUER_ID }}
    ASC_KEY_CONTENT: ${{ secrets.ASC_KEY_CONTENT }}   # base64 of the .p8
    MATCH_GIT_URL:   ${{ secrets.MATCH_GIT_URL }}
    MATCH_PASSWORD:  ${{ secrets.MATCH_PASSWORD }}
```
