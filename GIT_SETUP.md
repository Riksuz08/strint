# Connect strint to Git (GitHub)

Initial commit is already done. Next: create the remote repo and push.

## 1. Create a new repository on GitHub

1. Open **https://github.com/new**
2. **Repository name:** `strint` (or another name you prefer)
3. **Description:** Safe JSON models for Flutter — avoid crashes when backend sends wrong types
4. Choose **Public**
5. **Do not** add a README, .gitignore, or license (this project already has them)
6. Click **Create repository**

## 2. Connect and push from your machine

In the project folder run :

```bash
cd /Users/mac/strint

git remote add origin https://github.com/Riksuz08/strint.git
git branch -M main
git push -u origin main
```

If you use **SSH** instead of HTTPS:

```bash
git remote add origin git@github.com:Riksuz08/strint.git
git push -u origin main
```

## 3. Update pubspec.yaml

Set the real repo URL in `pubspec.yaml`:

- `homepage: https://github.com/Riksuz08/strint`
- `repository: https://github.com/Riksuz08/strint`

Then commit and push:

```bash
git add pubspec.yaml
git commit -m "Set repository URL"
git push
```

After that you can publish to pub.dev (`dart pub publish`).
