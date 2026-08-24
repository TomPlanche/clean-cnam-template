root := justfile_directory()

export TYPST_ROOT := root

[private]
default:
  @just --list --unsorted

# generate manual
doc:
  typst compile docs/thumbnail.typ thumbnail.svg

# run test suite
test *args:
  tt run {{ args }}

# update test cases
update *args:
  tt update {{ args }}

# list the shipped themes and document presets
themes:
  ./scripts/themes

# render a theme or preset and open it (name from `just themes`, or "none" / "all")
preview name="cnam" *args:
  ./scripts/preview "{{ name }}" {{ args }}

# render every theme and preset into docs/preview/
preview-all:
  ./scripts/preview all

# add a skeleton theme to src/lib/themes.typ
new-theme name:
  ./scripts/new-theme theme "{{ name }}"

# add a skeleton document preset to src/lib/themes.typ
new-preset name:
  ./scripts/new-theme preset "{{ name }}"

# package the library into the specified destination folder
package target:
  ./scripts/package "{{target}}"

# install the library with the "@local" prefix
install: (package "@local")

# install the library with the "@preview" prefix (for pre-release testing)
install-preview: (package "@preview")

[private]
remove target:
  ./scripts/uninstall "{{target}}"

# uninstalls the library from the "@local" prefix
uninstall: (remove "@local")

# uninstalls the library from the "@preview" prefix (for pre-release testing)
uninstall-preview: (remove "@preview")

# run ci suite
ci: test doc
