# Changelog

Notable changes to ORTools are listed here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow
[Semantic Versioning](https://semver.org/). Release notes for v3.0.1 and earlier are on the
[GitHub releases page](https://github.com/ORTools4MTEX/ORTools/releases).

## [Unreleased]

### Added
- CI on every pull request: pre-commit hooks and a strict documentation build.
- Automatic MATLAB code formatting with MISS_HIT through pre-commit.
- `CITATION.cff`, `CONTRIBUTING.md`, a pull request template and this changelog.
- Function index entries for `ensureFolder` and `plotCrystal_OR`.

### Changed
- `main` is now the only long-lived branch; `develop` is retired.
- All MATLAB source files are UTF-8 with LF line endings, so characters such as the degree sign
  display correctly in MATLAB R2020a and later.
- MATLAB code reformatted consistently (whitespace and indentation only).
- Documentation dependencies are pinned in `docs/requirements.txt`.

### Fixed
- Broken links to examples 1 and 2 in the documentation.
- `plotCrystal_OR` help text named the wrong function and input.

### Removed
- Duplicate `doc/images/` folder (the images live in `docs/images/`).
- Generated files in `data/output/`, which is no longer tracked.

## [3.0.1] - 2026-09-25

See the [release notes](https://github.com/ORTools4MTEX/ORTools/releases/tag/v3.0.1).

[Unreleased]: https://github.com/ORTools4MTEX/ORTools/compare/v3.0.1...HEAD
[3.0.1]: https://github.com/ORTools4MTEX/ORTools/releases/tag/v3.0.1
