# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [unreleased]

- Nothing.

## [2.1.0] - 2021-07-04

### Added

- `reset` function.

## [2.0.1] - 2021-07-04

### Changed

- make the width of the button label `El.fill` so that the user supplied label can be centered.
- make the default for `openOnMouseEnter` `False` so that this becomes an opt-in rather than an opt-out option.

### Fixed

- regression bug causing the button to need to be clicked twice to open the menu if the component does not have focus.

## [2.0.0] - 2021-06-26

### Added

- `setSelectedLabel` to set the selected option by its label.
- `Opened` & `Closed` `OutMsg`'s.
- `open` & `close` functions to programmatically open and close the menu.
- `getId` function.

### Changed

- internal `id`s.

  - The `id` of the element itself is now the `id` provided by the user.
  - The `id` of the button is the `id` provided by the user `++ "-button"`.
  - The `id` of the textfield is the `id` provided by the user `++ "-textfield"`.
  - The `id` of the menu is the `id` provided by the user `++ "-menu"`.
  - The `id` of a menu item is the `id` provided by the user `++ "-" ++ {item index}`.

## [1.8.1] - 2021-06-07

### Fixed

- no longer shows an empty menu (with border) if there are no matched options.

## [1.8.0] - 2021-06-06

### Added

- `text` function to retrieve the text entered in the `TextField`.

## [1.7.1] - 2021-06-06

### Fixed

- `TextField` input types now receive focus automatically when the mouse enters if `openOnMouseEnter` is set to `True`.

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

[unreleased]: https://github.com/phollyer/elm-ui-dropdown/compare/2.1.0...HEAD
[2.1.0]: https://github.com/phollyer/elm-ui-dropdown/compare/2.0.1...2.1.0
[2.0.1]: https://github.com/phollyer/elm-ui-dropdown/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/phollyer/elm-ui-dropdown/compare/1.8.1...2.0.0
[1.8.1]: https://github.com/phollyer/elm-ui-dropdown/compare/1.8.0...1.8.1
[1.8.0]: https://github.com/phollyer/elm-ui-dropdown/compare/1.7.1...1.8.0
[1.7.1]: https://github.com/phollyer/elm-ui-dropdown/compare/1.7.0...1.7.1
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
