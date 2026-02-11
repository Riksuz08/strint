# Publishing strint to pub.dev

## Before first publish

1. **Replace placeholder URLs** in `pubspec.yaml`:
   - Set `homepage` and `repository` to your real repo (e.g. `https://github.com/yourusername/strint`).

2. **Optional: create a verified publisher** at [pub.dev](https://pub.dev):
   - Sign in with Google → **Create Publisher** → enter your domain (e.g. `github.com/yourusername`).
   - Then you can publish under that publisher instead of your personal account.

## Publish steps

1. **From the package root** (`strint/`):

   ```bash
   cd /path/to/strint
   ```

2. **Check what will be published** (dry run):

   ```bash
   dart pub publish --dry-run
   ```

   - Fix any errors.
   - Optionally fix or ignore warnings (e.g. homepage/repository).

3. **Publish** (requires Google account):

   ```bash
   dart pub publish
   ```

   - You’ll be prompted to log in the first time.
   - Review the file list, then type `y` to upload.

4. **After publishing**

   - Package page: `https://pub.dev/packages/strint`
   - Users can add: `strint: ^0.0.1` in `pubspec.yaml`.

## Updating the package

1. Bump `version` in `pubspec.yaml` (e.g. `0.0.2`).
2. Add an entry to `CHANGELOG.md` for the new version.
3. Run:

   ```bash
   dart pub publish
   ```

## Notes

- **Publishing is permanent.** Old versions stay on pub.dev; you can only publish new versions.
- **Clean git:** `dart pub publish` will warn if you have uncommitted changes. Commit or stash first if you want a clean state.
- **`.pubignore`** is set so `lib/models/`, `strint_models.yaml`, and `build/` are not included in the published package.
