# Contributing to ORTools

Bug reports, questions and contributions are welcome. For questions and ideas, please use the
[Discussions board](https://github.com/ORTools4MTEX/ORTools/discussions); for bugs and feature
requests, [open an issue](https://github.com/ORTools4MTEX/ORTools/issues).

## Workflow

- `main` is the only long-lived branch. Create a branch from `main` for each change and open a pull
  request against `main`.
- Keep each pull request focused on one change.
- A pull request is merged once the `docs` check passes and it has been reviewed.

## Code formatting

MATLAB code is formatted automatically with [MISS_HIT](https://misshit.org), run through
[pre-commit](https://pre-commit.com) when you commit. CI does not run these checks, so please set
the hooks up once per clone:

```
pip install pre-commit
pre-commit install
```

From then on, the hooks format the files you commit. If a hook changes a file, the commit stops;
review the changes, `git add` them and commit again. To check the whole repository:

```
pre-commit run --all-files
```

The formatting rules are in `miss_hit.cfg`. Vendored third-party code in `library/` is not
formatted. To make `git blame` skip the commit that reformatted the code base:

```
git config blame.ignoreRevsFile .git-blame-ignore-revs
```

## Documentation

The documentation site is built with MkDocs from `docs/`. When adding or changing a function in
`src/`, update its entry in `docs/function_index.md`. To preview the site locally:

```
pip install -r docs/requirements.txt
mkdocs serve
```

CI builds the site with `mkdocs build --strict`, so broken links fail the pull request.

## Code of conduct

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md).
