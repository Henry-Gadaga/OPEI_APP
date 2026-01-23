# GitHub Actions: Android signing (production)

This repo’s Android Gradle config reads signing values from `android/key.properties`. **Do not commit** `android/key.properties` or any `.jks` keystore.

## Required GitHub Secrets

Create these GitHub repo secrets:

- `ANDROID_KEYSTORE_BASE64`: base64 of your `.jks` file
- `ANDROID_KEYSTORE_PASSWORD`: keystore password
- `ANDROID_KEY_PASSWORD`: key password
- `ANDROID_KEY_ALIAS`: key alias

Once present, `.github/workflows/flutter-ci.yml` will:

- Decode the keystore to `android/app/upload-keystore.jks`
- Generate `android/key.properties` during CI
- Build `flutter build appbundle --flavor prod --release`
- Upload the `.aab` as a workflow artifact

## How to create `ANDROID_KEYSTORE_BASE64` (macOS)

```bash
base64 -i path/to/your-upload-keystore.jks | pbcopy
```

Paste into the GitHub secret `ANDROID_KEYSTORE_BASE64`.

## Local dev (no signing)

You can still build/run without signing secrets:

- `flutter run`
- `flutter build apk --debug`

The Gradle config falls back to debug signing when `android/key.properties` is missing.

## IMPORTANT: Rotate + purge leaked signing material

If a keystore or passwords were ever committed, **assume compromise**:

- Generate a new upload keystore + new passwords.
- Remove the old secrets from git history (so they’re not recoverable).

One approach (requires `git-filter-repo`):

```bash
git filter-repo --path android/key.properties --path android/app/opei-upload.jks --invert-paths
```

Then force-push the rewritten history and have all contributors re-clone.

