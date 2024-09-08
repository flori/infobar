# Changes

## 2024-09-08 v0.8.1

* **Dependency Updates**:
	+ Update `all_images` Dockerfile and Gem installation
		- Removed gem update and `gem_hadar/bundler` installation from Dockerfile
		- Replaced RUN commands with bundle install and rake spec using bundler
	+ Upgrade `gem_hadar`
* **Refactor Infobar message formatting**
	+ Update `@message` assignment to use a conditional format string
* **Miscellaneous**:
	+ Bump version and dependencies
		- Update `.all_images.yml` to use `bundle install --full-index`
		- Remove `.byebug_history` from `.gitignore`
		- Remove `gem 'byebug', platform: :mri'` from `Gemfile`
		- Bump version in `VERSION`, `infobar.gemspec`, and `lib/infobar/version.rb`

## 2024-09-01 v0.8.0

* **New Version:** 0.8.0
* **Significant Changes:**
	+ *Update all_images Dockerfile and Gem installation*
		- Removed gem update and gem_hadar/bundler installation from Dockerfile
		- Replaced RUN commands with bundle install and rake spec using bundler
	+ *Add string representation for Infobar::Counter*
		- Added test for representing Infobar::Counter as a string
		- Updated test to check progress method with different options
	+ *Update Infobar busy method to accept frames option*
		- Update busy method to take an optional frames parameter with default value :circle1
		- Change message format in busy method to use frames option instead of hardcoded :circle1 symbol

## 2024-03-15 v0.7.4

* **Ruby Compatibility**: Skip testing Rubies less than 3.

## 2024-03-15 v0.7.3

* **New Features**
	+ Updated homepage URL to use HTTPS
	+ Integrated latest `gem_hadar` gem
* **Changes**
	+ Homepage URL updated to secure protocol

## 2023-10-09 v0.7.2

* Changed homepage link.

## 2023-10-09 v0.7.1

* **New Feature**: Added `all_images` feature for testing purposes.
* **Bug Fix**: Reset is now performed before entering busy mode.

## 2021-01-12 v0.7.0

* **New Features**
	+ Support for Ruby 3.0
* **Dependencies**
	+ Depend on the newest version of an unspecified library or framework

## 2020-05-15 v0.6.2

* **Significant Changes**:
	+ Use keyword operator
	+ Upgrade bundler
	+ Test ruby 2.7
	+ Remove unnecessary code

## 2019-04-11 v0.6.1

* **Output Counter Results**: The `to_s` method has been added to output the results of counters.

## 2019-01-31 v0.6.0

* **Progressing with '-' allowed**: The code now allows progressing with a '-' character, treating it as equivalent to `false`.

## 2018-11-01 v0.5.1

* **Allow busy bar message to be overwritten**
	+ Added functionality to overwrite the default busy bar message.

## 2018-03-05 v0.5.0

* **New Feature:** Allow counter values to be formatted with units.

## 2017-12-08 v0.4.0

* **New Feature**: Automatically iterate when `with_infobar` is passed a block.
	+ This change allows for more flexible usage of the `with_infobar` method.
* **Documentation**: Add COPYING file
	+ Provides licensing information for the project.

## 2017-06-29 v0.3.0

* **New Feature:** Smart duration formatting is now used by default.
* **New Feature:** Long integers are separated with underscores by default.

## 2017-05-24 v0.2.0

* **New Feature**: Allow setting of input/output on initial call. 

### Changes:

* Added functionality to set input and output streams on the first method call.

## 2017-05-04 v0.1.1

* **Avoid outputting to display during instance init**: 
  * Prevent unnecessary output during instance initialization.

## 2017-04-24 v0.1.0

* **New Features**
	+ Support for multiple colored progress bars
* **Bug Fixes**
	+ Ensure bar is always long enough
	+ Correct config environment settings

## 2017-04-13 v0.0.7

* **New Feature:** Forced display of Infobar updates:
	+ When calling `Infobar.update`, the infobar will now always be displayed.

## 2017-03-24 v0.0.6

* Added busy bar functionality.

## 2017-03-10 v0.0.5

* **Always Provide Default Unit**: Added functionality to always provide a
  default unit, ensuring consistency in output.

## 2017-03-10 v0.0.4

* **Rate Validation**: Fixed issue where invalid rates were not handled
  correctly at the beginning of a calculation.

## 2017-03-09 v0.0.3

* **New Version Summary**
	+ Reset frequency when calling `clear`
	+ Added reminder to TODO list
	+ Fixed a typo

## 2017-02-10 v0.0.2

* Added trend arrow to rate directive.

## 2017-02-08 v0.0.1

* Added new features and functionality. 

### Significant Changes:

* **New Features**: Additional tasks were added to the system.

## 2017-02-08 v0.0.0

  * Start
