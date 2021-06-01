# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [unreleased]

- Nothing at the moment.

## [1.1.1] - 2021-06-01

### Changed

- Clicking the Button when the menu is open will now close the menu.

## [1.1.0] - 2021-06-01

### Added

- `buttonlabel` function in order to set the text on the Button when nothing is selected. The default is "-- Select --".

### Moved

- The default Element attributes are now set in the view rather than on the model. This is so that they don't all get overwritten at once when the user adds their custom attributes.

## [1.0.1] - 2021-05-31

### Fixed

- Issue #1 - Menu now closes when clicking outside if opened by clicking the label - typo.

## [1.0.0] - 2021-05-31

### Added

- Initial Commit.

[unreleased]: https://github.com/phollyer/elm-ui-dropdown/compare/1.1.1...HEAD
[1.1.1]: https://github.com/phollyer/elm-ui-dropdown/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/phollyer/elm-ui-dropdown/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/phollyer/elm-ui-dropdown/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/phollyer/elm-ui-dropdown/releases/tag/v1.0.0
