# Releasing

1) Update `CHANGELOG.md` with the new version notes.
2) Commit your changes.
3) Tag the release:

```bash
git tag -a vX.Y.Z -m "vX.Y.Z"
```

4) Push the tag:

```bash
git push origin vX.Y.Z
```

5) Create a GitHub Release for the tag. The `release` workflow will upload
   `ralph.tar.gz` and `ralph.zip` assets.

## Release notes template

```markdown
## vX.Y.Z
- Highlight 1
- Highlight 2
- Highlight 3
```

## Local asset build (optional)

```bash
./scripts/build-release-assets.sh
```
