# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [unreleased]

- Nothing.

## [1.7.0] - 2021-06-06

### Added

- `list` function to retrieve a list of option data in the form `(Int, String, option)` (`(index, label, option)`).
- `listOptions` function to retrieve the list of `option`s.
- `listLabels` function to retrieve a list of the labels for each `option`.

## [1.6.0] - 2021-06-06

### Added

- `selectedLabel` function to retrieve the label of the selected option.

## [1.5.1] - 2021-06-03

### Updated

- docs.

## [1.5.0] - 2021-06-03

### Added

- `removeOption` function to remove an option from the internal list.

## [1.4.0] - 2021-06-03

### Added

- the menu opens automatically when the mouse enters, and closes when the
  mouse leaves.

- `openOnMouseEnter` function to decide if the the menu opens when the mouse enters
  and closes when the mouse leaves. The default is `True`.

## [1.3.0] - 2021-06-03

### Added

- `isOpen` function to determine if the dropdown is open or closed.

## [1.2.1] - 2021-06-02

### Fixed

- set the text in the `TextField` appropriately when `setSelected` is called:
  - when `Nothing` -> use an empty `String`
  - when `Just` -> use the selected option's label

## [1.2.0] - 2021-06-01

### Added

- `setSelected` function to enable setting the selected option manually.

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

[unreleased]: https://github.com/phollyer/elm-ui-dropdown/compare/1.7.0...HEAD
[1.7.0]: https://github.com/phollyer/elm-ui-dropdown/compare/1.6.0...1.7.0
[1.6.0]: https://github.com/phollyer/elm-ui-dropdown/compare/1.5.1...1.6.0
[1.5.1]: https://github.com/phollyer/elm-ui-dropdown/compare/1.5.0...1.5.1
[1.5.0]: https://github.com/phollyer/elm-ui-dropdown/compare/1.4.0...1.5.0
[1.4.0]: https://github.com/phollyer/elm-ui-dropdown/compare/1.3.0...1.4.0
[1.3.0]: https://github.com/phollyer/elm-ui-dropdown/compare/1.2.1...1.3.0
[1.2.1]: https://github.com/phollyer/elm-ui-dropdown/compare/1.2.0...1.2.1
[1.2.0]: https://github.com/phollyer/elm-ui-dropdown/compare/1.1.1...1.2.0
[1.1.1]: https://github.com/phollyer/elm-ui-dropdown/compare/1.1.0...1.1.1
[1.1.0]: https://github.com/phollyer/elm-ui-dropdown/compare/1.0.1...1.1.0
[1.0.1]: https://github.com/phollyer/elm-ui-dropdown/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/phollyer/elm-ui-dropdown/releases/tag/v1.0.0
