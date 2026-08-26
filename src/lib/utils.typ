/**
 * Utility functions for the TYPST template
 */

#import "@preview/orchid:0.1.0": generate-link

/**
 * Deep-merge a user patch into a base dictionary.
 *
 * Recursion happens only when both sides hold a dictionary, so a scalar default
 * (`none`, `auto`, a length) is always replaced wholesale by whatever the user passes.
 *
 * Every key of `patch` must exist in `base`: a typo raises an error naming the offending
 * path and listing the valid keys, instead of being silently dropped as a `+` merge would.
 *
 * A few dictionaries are open-ended by nature: `code.lang-colors` is a lookup table the
 * user is meant to extend with languages the template never heard of. `open` lists their
 * root-relative paths, and their contents merge without key validation.
 *
 * @param base - The reference dictionary (also the source of truth for valid keys)
 * @param patch - The user-supplied overrides
 * @param path - Dotted path of `base`, used to build error messages
 * @param open - Root-relative dotted paths whose contents accept unknown keys
 * @returns The merged dictionary
 */
#let merge-dicts(base, patch, path: "config", open: ()) = {
  assert(
    type(patch) == dictionary,
    message: "`" + path + "` must be a dictionary, found " + str(type(patch)),
  )

  let out = base

  for (key, value) in patch {
    let child-path = path + "." + key

    // The root segment is the caller's label ("config" or "theme"), so compare what
    // follows it: an open path is open whichever layer it arrives from.
    if child-path.split(".").slice(1).join(".") in open {
      assert(
        type(value) == dictionary,
        message: "`" + child-path + "` must be a dictionary, found " + str(type(value)),
      )
      out.insert(key, base.at(key, default: (:)) + value)
      continue
    }

    if key not in base {
      panic(
        "unknown option `" + child-path + "`. Valid keys for `" + path + "`: "
          + base.keys().sorted().join(", "),
      )
    }

    let current = base.at(key)

    out.insert(
      key,
      if type(current) == dictionary and type(value) == dictionary {
        merge-dicts(current, value, path: child-path, open: open)
      } else {
        value
      },
    )
  }

  out
}

/**
 * Normalize the `info.author` option to an array.
 *
 * Accepts a string, a dict, or an array mixing both.
 *
 * @param author - The raw author option
 * @returns An array of authors
 */
#let author-list(author) = {
  if type(author) in (str, dictionary) { (author,) } else { author }
}

/**
 * Extract plain author names, for `set document(author: ..)`.
 *
 * @param author - The raw author option
 * @returns An array of strings
 */
#let author-names(author) = {
  author-list(author).map(a => if type(a) == str { a } else { a.name })
}

/**
 * Render the author list as displayable content, with optional ORCID and mailto links.
 *
 * - orcid only: name and ORCID icon are combined into a single link to orcid.org
 * - email only: the name becomes an underlined `mailto:` link
 * - both: the name links to `mailto:`, the ORCID icon links separately to orcid.org
 *
 * @param author - The raw author option
 * @returns Content with one author per line
 */
#let format-authors(author) = {
  author-list(author)
    .map(a => {
      if type(a) == str {
        return a
      }

      let addr = if "email" in a and a.email != none {
        a.email
      } else if "mail" in a and a.mail != none {
        a.mail
      } else {
        none
      }

      if "orcid" in a and a.orcid != none {
        let orcid-id = if type(a.orcid) == str { a.orcid } else { a.orcid.id }
        let orcid-name = if type(a.orcid) == dictionary and "name" in a.orcid and a.orcid.name != none {
          a.orcid.name
        } else {
          a.name
        }

        if addr != none {
          // name -> mailto:, ORCID icon -> orcid.org
          generate-link(orcid-id) + [~] + link("mailto:" + addr, underline(orcid-name))
        } else {
          generate-link(orcid-id, name: orcid-name)
        }
      } else if addr != none {
        link("mailto:" + addr, underline(a.name))
      } else {
        a.name
      }
    })
    .join("\n")
}

/**
 * Format a date to French format (DD/MM/YYYY).
 *
 * Converts a datetime object to the standard French date format
 * used throughout the document template.
 *
 * @param date - The datetime object to format
 * @returns A formatted date string in DD/MM/YYYY format
 */
#let date-format = (date) => {
    date.display("[day]/[month]/[year]")
}

/**
 * Create an icon with proper sizing and spacing.
 *
 * Wraps an image in a box with consistent sizing and adds appropriate
 * horizontal spacing for inline use within text.
 *
 * @param codepoint - The image/icon file to display
 * @returns A properly sized and spaced icon element
 */
#let icon(codepoint) = {
  box(
    height: 1em,
    baseline: 0.1em,
    image(codepoint)
  )
  h(0.1em)
}

/**
 * Helper function for vector arrow notation in math mode.
 *
 * Creates vector notation by placing a harpoon accent over the given variable name.
 * Commonly used in mathematical expressions for vector quantities.
 *
 * @param name - The variable name to put an arrow over
 * @returns Math expression with harpoon arrow accent
 */
#let ar = name => $accent(#name, harpoon)$

/**
 * Create a thin horizontal line with specified color.
 *
 * @param color - The color for the line
 * @returns A thin horizontal line element
 */
#let thin-line = (color) => line(length: 100%, stroke: 0.6pt + color)
