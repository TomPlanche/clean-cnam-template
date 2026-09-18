# CNAM TYPST Template

A modular Typst template for CNAM documents: cover page, decorated chapter pages, front matter, and components (blocks, quotes, code, math environments) that all follow one configuration object.

Originally based on [hzkonor's bubble-template](https://github.com/hzkonor/bubble-template) and uses [CNAM](https://www.cnam.fr/)'s logo and colors. The code block styling is adapted from [typst-endfield-doc-theme](https://github.com/Ives-Natsume/typst-endfield-doc-theme).

> **Every option, every parameter, every detail: [REFERENCE.md](REFERENCE.md).** This page is the tour.

## Quick Start

```typst
#import "@preview/clean-cnam-template:2.0.0": *

#show: clean-cnam-template.with(config: (
  info: (
    title: "Report Title",
    subtitle: "Subtitle",
    author: "Tom Planche",
    class: "Course name",
    logo: image("assets/cnam_logo.svg"),
    start-date: datetime(day: 4, month: 9, year: 2024),
  ),
  colors: (primary: "#C4122E"),
))

= First chapter     // opens a decorated chapter page
== A section
```

Working on this repository instead of the published package? Import `src/lib.typ`:

```typst
#import "src/lib.typ": *
```

The template pulls `great-theorems`, `hydra`, `i-figured`, `headcount` and `orchid` from Typst Universe (downloaded on first compile), and expects the `New Computer Modern Math` and `Zed Plex Mono` fonts, both replaceable through [`fonts`](REFERENCE.md#font-configuration).

## Components

| Component | What it is |
|-----------|------------|
| `#blockquote[..]` | Quote block with an accent border on any side, optional attribution |
| `#my-block[..]` | Callout block with an optional title, width and alignment control |
| `#code(lang: .., <raw block>)` | Code block with line numbers, ranges, filename tab and a color per language |
| `#definition(title: ..)[..]` | Math definition environment |
| `#example(title: ..)[..]` | Math example environment |
| `#theorem(title: ..)[..]` | Math theorem environment |
| `#ar(v)` | Vector arrow notation, `$ar(v)$` |
| `#icon("..")` | Inline icon, sized and spaced for running text |
| `#date-format(datetime(..))` | A date in `DD/MM/YYYY` |
| `#no-numbering()` | Next heading keeps its style but loses its number |
| `#no-big-title()` | Next `=` heading stays in the flow instead of opening a chapter page |

```typst
#definition(title: "Linearity")[
  $phi$ is linear when $phi(lambda x + mu y) = lambda phi(x) + mu phi(y)$.
]
```

`#code()` takes a raw block, with the language and an optional filename shown in a tab (written here with `raw(..)` rather than a nested fence, which Markdown cannot show):

```text
#code(
  lang: "Rust",
  filename: "src/main.rs",
  raw(block: true, lang: "rust", "fn main() { println!(\"Hello\"); }"),
)
```

Every component reads the palette and the fonts from the configuration, so restyling the document does not mean restyling each call site. Per-call parameters still win -- see [Components](REFERENCE.md#components) and [Code Blocks](REFERENCE.md#code-blocks).

## Front Matter

`front-matter.pages` is the ordered list of pages between the cover and the body. One entry, one page, in the order given -- which is also how the table of contents is placed.

```typst
front-matter: (pages: (
  "blank",                                          // an empty page
  "cover-text",                                     // the cover text again, without the logo
  (title: "Foreword", body: [ ... ]),               // a section of your own
  (title: "Acknowledgements", body: thanks),        // ... or a (cfg) => content function
  "outline",                                        // the table of contents
  "figures",                                        // the list of figures
  "tables",                                         // the list of tables
)),
```

That list happens to be the EiCnam dissertation layout, [spelled out in full](REFERENCE.md#a-full-front-matter) in the reference. The default is `("outline",)`: cover, table of contents, body. Sections of your own are unnumbered and listed in the table of contents unless they pass `outlined: false`; a bare content entry becomes an untitled page.

Page numbering has two anchors, both `auto` by default (numbering starts on the first page of the body, printing that page's own position):

```typst
page: (numbering-start: 1)                      // the body opens at 1
page: (numbering-from: 2)                       // numbering starts on page 2: 2, 3, 4, ...
page: (numbering-from: 2, numbering-start: 3)   // starts on page 2, printing 3, 4, 5, ...
```

More in [Front Matter](REFERENCE.md#front-matter) and [Page Numbering](REFERENCE.md#page-numbering).

## Customization

Everything goes through the single `config` dictionary. Overrides are partial at every depth, and an unknown key is an error naming the valid ones rather than a silent no-op.

```typst
#show: clean-cnam-template.with(config: (
  colors: (primary: rgb("#00539F"), secondary: auto),   // auto = derived from primary
  fonts: (title: (name: "Inter", weight: 700)),         // the weight cascades from `default`
  page: (margin: (left: 2.5cm)),                        // the other margins stay put
  cover: (decorations: false, title: (size: 3em)),
  headings: (chapter-style: "plain"),                   // level-1 headings stay in the flow
  outline: (depth: 2),
  print: true,                                          // no link color or underline
))
```

| Section | Covers | Details |
|---------|--------|---------|
| `info` | title, subtitle, author(s), class, dates, logo | [reference](REFERENCE.md#info----document-metadata-and-cover-content) |
| `colors` | primary, secondary, outline, page number, neutral ramp, math environments | [reference](REFERENCE.md#colors----semantic-palette) |
| `fonts` | default, body, title, chapter, code, inline code, base size | [reference](REFERENCE.md#fonts----typography) |
| `page` | margins, numbering pattern and anchors, number alignment | [reference](REFERENCE.md#page----page-setup) |
| `cover` | background, decorations, second logo, and one dict per cover element | [reference](REFERENCE.md#cover-page-customization) |
| `code` | accent and background, plus a color per language | [reference](REFERENCE.md#code----code-block-colors) |
| `render` | hooks replacing the cover, decorations, header, footer or chapter page | [reference](REFERENCE.md#rendering-hooks) |
| `headings` | chapter style, page break and "Chapitre N" label | [reference](REFERENCE.md#headings----level-1-heading-rendering) |
| `outline` | enabled, custom content, indent, depth | [reference](REFERENCE.md#outline----table-of-contents) |
| `front-matter` | the pages between the cover and the body | [reference](REFERENCE.md#front-matter) |
| `lang`, `print`, `color-words` | language, print mode, auto-highlighted words | [reference](REFERENCE.md#top-level-keys) |

### Themes and Presets

A theme is a partial configuration applied *under* your own, so anything it sets stays overridable. Pass an array to compose several, later layers winning:

```typst
#show: clean-cnam-template.with(
  theme: (presets.memoire, themes.sobre),
  config: (info: (title: "Mémoire")),
)
```

| Layer | Effect |
|-------|--------|
| `themes.cnam` | The defaults, spelled out |
| `themes.sobre` | No decorative circles, neutral cover text |
| `themes.dark` | Dark cover with white text |
| `themes.monochrome` | Greyscale palette for black and white printing |
| `presets.article` | Short pieces: in-flow level-1 headings, no decorations, tighter margins |
| `presets.memoire` | Wider binding margin, two-level outline, date range on the cover |
| `presets.tp` | Compact lab reports: 11pt body, tight margins, no outline |

Writing your own is writing a dictionary -- see [Themes and Presets](REFERENCE.md#themes-and-presets).

## Development

Recipes for working on the template itself, none of which ship in the package:

| Command | Effect |
|---------|--------|
| `just themes` | List the shipped themes and presets, read from `src/lib/themes.typ` |
| `just preview sobre` | Render `docs/preview.typ` with that theme or preset and open the PDF |
| `just preview-all` | Render every theme and preset into `docs/preview/` |
| `just new-theme NAME` / `just new-preset NAME` | Scaffold a skeleton entry |
| `just test` | Run the test suite ([tytanic](https://github.com/typst-community/tytanic), binary `tt`) |

Without tytanic installed, the tests are plain Typst documents whose assertions fail the compilation:

```bash
for t in tests/*/test.typ; do echo "== $t"; typst compile --root . "$t" --format pdf - >/dev/null; done
```

More in [Development](REFERENCE.md#development) and [Project Structure](REFERENCE.md#project-structure); [CHANGELOG.md](CHANGELOG.md) has what changed when.

## Author

- **Tom Planche**

## Acknowledgements

- [hzkonor/bubble-template](https://github.com/hzkonor/bubble-template), the original basis for this template.
- [Ives-Natsume/typst-endfield-doc-theme](https://github.com/Ives-Natsume/typst-endfield-doc-theme) by metasequoiaNI (MIT), the source of the code block styling.
- [github-linguist/linguist](https://github.com/github-linguist/linguist) (MIT), the source of the per-language colors in `code.lang-colors`.

## License

MIT
