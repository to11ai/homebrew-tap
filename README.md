# to11ai Homebrew tap

```bash
brew install to11ai/tap/to11
```

Homebrew strips the `homebrew-` prefix, so this repository is the tap `to11ai/tap`.

## Releasing

`Formula/to11.rb` is generated — edit `templates/to11.rb.tmpl`, not the formula.

Each CLI release in the private monorepo sends a `repository_dispatch` here, and
[`update-formula.yml`](.github/workflows/update-formula.yml) re-renders the formula from
the release's own `checksums.txt`, checks it with `brew style`, `brew audit --strict` and
an install smoke test, and commits it. To re-render by hand, run the workflow with a
version, or locally:

```bash
./scripts/render-formula.sh 0.5.0
```
