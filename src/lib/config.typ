/**
 * Main configuration for CNAM document template
 *
 * This template can be used to create reports using CNAM branding.
 */

// modules
#import "store.typ": default-config, get-config, get-fonts, resolve-config, set-config
#import "components.typ": blockquote, code, my-block
#import "layout.typ": add-decorations, apply-styling, create-title-page, no-big-title, no-numbering
#import "utils.typ": ar, author-names, format-authors, icon, merge-dicts

// Re-export components for easy access
#let blockquote = blockquote
#let my-block = my-block
#let code = code
#let icon = icon
#let ar = ar

/**
 * Main configuration function for the document template.
 *
 * Everything is passed through a single nested `config` dictionary, merged over
 * `default-config` and published to a document-wide state that every component reads.
 * Overrides are partial at any depth: `(cover: (title: (size: 3em)))` keeps the other
 * cover settings untouched. An unknown key is an error, not a silent no-op.
 *
 * ```typst
 * #show: clean-cnam-template.with(config: (
 *   info: (title: "Rapport", author: "Tom Planche", logo: image("logo.svg")),
 *   colors: (primary: "#C4122E"),
 *   fonts: (title: (name: "Inter", weight: 700)),
 *   cover: (title: (size: 3em), decorations: false),
 * ))
 * ```
 *
 * Sections of the configuration tree, all optional:
 *
 * - `info`: title, subtitle, subsubtitle, author, affiliation, class, year, start-date,
 *   last-updated-date, logo. `author` accepts a string, a dict
 *   `(name, orcid, email)` or an array mixing both. `orcid` alone links the name to
 *   orcid.org, `email` alone makes it a mailto: link, both split the two links.
 * - `colors`: primary (color or hex string), secondary, outline, page-number, the
 *   `neutral-*` ramp used by the components, and definition / example / theorem.
 *   `auto` means derived: secondary from primary, outline and page-number from the text color.
 * - `fonts`: default, body, title, chapter, code, inline-raw, size. Each font is a
 *   `(name, weight)` dict (`chapter` also takes `size`); `auto` members cascade from
 *   `default`, or from `title` for `chapter` and from `body` for `inline-raw`.
 * - `page`: margin (top, right, bottom, left), numbering, number-align.
 * - `cover`: bg, decorations, second-logo (image, scale, dx, dy), padding, spacing, and one
 *   dict per element (title, subtitle, subsubtitle, date, author) with text, color, weight,
 *   size, font and align. A `text` key overrides the matching `info` field.
 * - `outline`: enabled, custom (content rendered instead of the default outline), indent.
 * - `lang`, `print`, `color-words`, `show-secondary-header`.
 *
 * @param config - Partial configuration dictionary, merged over `default-config`
 * @param body - Document content
 */
#let clean-cnam-template(
  config: (:),
  body,
) = {
  // Merge over the defaults, reject unknown keys, resolve every `auto` cascade
  let cfg = resolve-config(config)

  // Publish the resolved config so components can follow the theme
  set-config(cfg)

  // Document metadata
  set document(author: author-names(cfg.info.author), title: cfg.cover.title.text)
  set text(lang: cfg.lang)

  // Apply page margins and cover background (none = transparent)
  set page(margin: cfg.page.margin, fill: cfg.cover.bg)

  // Conditionally add decorative elements
  if cfg.cover.decorations {
    add-decorations(cfg)
  }

  // Create title page
  create-title-page(cfg)

  // Apply main styling and render body content
  apply-styling(cfg, body)
}
