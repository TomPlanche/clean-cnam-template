/**
 * Main configuration for CNAM document template
 *
 * This template can be used to create reports using CNAM branding.
 *
 * @author Tom Planche
 * @license MIT
 */

// Import all modules
#import "fonts.typ": set-fonts
#import "components.typ": blockquote, my-block, code
#import "layout.typ": apply-styling, add-decorations, create-title-page, page-margin
#import "utils.typ": icon, ar

// Re-export components for easy access
#let blockquote = blockquote
#let my-block = my-block
#let code = code
#let icon = icon
#let ar = ar

/**
 * Main configuration function for the document template.
 *
 * @param title - Document title
 * @param subtitle - Document subtitle
 * @param author - Author name (string) or list of authors (array of strings)
 * @param affiliation - Author's affiliation/institution
 * @param year - Year for school year calculation
 * @param class - Class/course name
 * @param start-date - Document start date (use none to hide the date)
 * @param last-updated-date - Last updated date
 * @param logo - Logo image to display
 * @param main-color - Primary color for the theme (hex string)
 * @param color-words - Array of words to highlight with primary color
 * @param default-font - Default font object (name: string, weight: int/string) for body text
 * @param body-font - Font object for body text (defaults to default-font)
 * @param title-font - Font object for titles and headings (defaults to default-font)
 * @param code-font - Font object for code blocks and monospace text
 * @param show-secondary-header - Whether to show secondary headers (with sub-heading)
 * @param language - Language code ("fr" for French, "en" for English)
 * @param outline-code - Custom outline code (none for default, false to disable, or custom content)
 * @param cover - Cover page configuration dictionary with keys:
 *   bg: page background color (none = transparent)
 *   decorations: toggle decorative circles (true/false)
 *   title: dict with color, weight, size, font (auto = primary-color / title-font.name)
 *   subtitle: dict with color, weight, size, font (auto = title color / title-font.name)
 *   date: dict with color, weight, size, font (auto = title color / body-font)
 *   author: dict with color, weight, size, font (auto = title color / body-font)
 * @param body - Document content
 */
#let clean-cnam-template(
  title: "",
  subtitle: "",
  author: "",
  affiliation: "",
  year: datetime.today().year(),
  class: none,
  start-date: datetime.today(),
  last-updated-date: datetime.today(),
  logo: none,
  main-color: "E94845",
  color-words: (),
  default-font: (name: "New Computer Modern Math", weight: 400),
  body-font: none,
  title-font: none,
  code-font: (name: "Zed Plex Mono", weight: 400),
  show-secondary-header: true,
  language: "fr",
  outline-code: none,
  cover: (:),
  body,
) = {
  // Set global font configuration
  set-fonts(default-font: default-font, code-font: code-font)

  // Font configuration - use default-font as fallback
  let body-font = if body-font == none { default-font } else { body-font }
  let title-font = if title-font == none { default-font } else { title-font }

  // Color configuration
  let primary-color = rgb(main-color)
  let secondary-color = primary-color.lighten(30%)

  // Cover page configuration - deep merge with defaults
  let default-cover = (
    bg: none,
    decorations: true,
    padding: 1em,
    spacing: 1em,
    title: (
      color: auto,
      weight: 700,
      size: 2.5em,
      font: auto,
    ),
    subtitle: (
      color: auto,
      weight: 700,
      size: 2em,
      font: auto,
    ),
    date: (
      color: auto,
      weight: auto,
      size: 1.1em,
      font: auto,
      range: true,
    ),
    author: (
      color: auto,
      weight: "bold",
      size: 14pt,
      font: auto,
    ),
  )

  let final-cover = default-cover + cover
  for key in ("title", "subtitle", "date", "author") {
    if key in cover {
      final-cover.insert(key, default-cover.at(key) + cover.at(key))
    }
  }

  // Resolve auto values (title first, others cascade from title)
  if final-cover.title.color == auto {
    final-cover.title.color = primary-color
  }
  if final-cover.title.font == auto {
    final-cover.title.font = title-font.name
  }
  if final-cover.subtitle.color == auto {
    final-cover.subtitle.color = final-cover.title.color
  }
  if final-cover.subtitle.font == auto {
    final-cover.subtitle.font = title-font.name
  }
  if final-cover.date.color == auto {
    final-cover.date.color = final-cover.title.color
  }
  if final-cover.date.weight == auto {
    final-cover.date.weight = body-font.weight
  }
  if final-cover.date.font == auto {
    final-cover.date.font = body-font.name
  }
  if final-cover.author.color == auto {
    final-cover.author.color = final-cover.title.color
  }
  if final-cover.author.font == auto {
    final-cover.author.font = body-font.name
  }

  // Normalize author to array and create display string
  let author-list = if type(author) == str { (author,) } else { author }
  let author-display = author-list.join("\n")

  // Document metadata
  set document(author: author-list, title: title)
  set text(lang: language)

  // Apply page margins and cover background (none = transparent, the default)
  set page(margin: page-margin, fill: final-cover.bg)

  // Conditionally add decorative elements
  if final-cover.decorations {
    add-decorations(primary-color, secondary-color)
  }

  // Create title page
  create-title-page(
    title,
    subtitle,
    author-display,
    affiliation,
    class,
    start-date,
    last-updated-date,
    year,
    primary-color,
    title-font,
    body-font,
    logo,
    outline-code,
    final-cover,
  )

  // Apply main styling and render body content
  apply-styling(
    primary-color,
    secondary-color,
    body-font,
    title-font,
    author-display,
    color-words,
    show-secondary-header,
    language,
    body
  )
}
