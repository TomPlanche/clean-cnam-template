# CNAM TYPST Template

A Typst template for CNAM documents. It gives you a cover page, chapter pages, front matter, and components for your text: blocks, quotes, code blocks, and math environments.

One configuration dictionary controls the whole document. Every component reads it.

> **This page shows you how to write a document with the template. [REFERENCE.md](REFERENCE.md) lists every option.**

## Start a document

Import the package. Then apply the template with your configuration:

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

= First chapter     // a level-1 heading opens a chapter page
== A section
```

Typst downloads the packages of the template on the first compile. The template uses two fonts: `New Computer Modern Math` for the text and `Zed Plex Mono` for the code. Install these two fonts, or name your own fonts in the `fonts` section.

If you work from a copy of this repository, import the source instead:

```typst
#import "src/lib.typ": *
```

## Write the text

Write your text with the components below. Each component reads the colors and the fonts of the configuration. You do not set a style again at each use.

| Component | What it does |
|-----------|--------------|
| `#blockquote[..]` | A quote with a colored border on one side, and an optional attribution |
| `#my-block[..]` | A callout with an optional title. You control the width and the alignment. |
| `#code(lang: .., <raw block>)` | A code block with line numbers, a filename tab, and one color per language |
| `#definition(title: ..)[..]` | A math definition |
| `#example(title: ..)[..]` | A math example |
| `#theorem(title: ..)[..]` | A math theorem |
| `#ar(v)` | A vector arrow, as in `$ar(v)$` |
| `#icon("..")` | An icon in the text, at the size of the text |
| `#date-format(datetime(..))` | A date in the `DD/MM/YYYY` form |
| `#no-numbering()` | The next heading keeps its style and loses its number |
| `#no-big-title()` | The next `=` heading stays in the text and opens no chapter page |

```typst
#definition(title: "Linearity")[
  $phi$ is linear when $phi(lambda x + mu y) = lambda phi(x) + mu phi(y)$.
]
```

`#code()` takes a raw block. The example below writes that raw block with `raw(..)`, because Markdown cannot show a code fence inside a code fence:

```text
#code(
  lang: "Rust",
  filename: "src/main.rs",
  raw(block: true, lang: "rust", "fn main() { println!(\"Hello\"); }"),
)
```

Read [Components](REFERENCE.md#components) and [Code Blocks](REFERENCE.md#code-blocks) for every parameter.

## Build the front matter

The front matter is the group of pages between the cover and the body. You list these pages in `front-matter.pages`. Each entry makes one page, and the pages come in the order of the list. The list also places the table of contents.

```typst
front-matter: (pages: (
  "blank",                                          // an empty page
  "cover-text",                                     // the text of the cover again, without the logo
  (title: "Foreword", body: [ ... ]),               // a section of your own
  (title: "Acknowledgements", body: thanks),        // ... or a (cfg) => content function
  "outline",                                        // the table of contents
  "figures",                                        // the list of figures
  "tables",                                         // the list of tables
)),
```

This list is the front matter of an EiCnam dissertation. The reference [writes it in full](REFERENCE.md#a-full-front-matter).

Three rules apply to the entries:

- The default list is `("outline",)`. You get the cover, the table of contents, then the body.
- The template writes your sections without a number, and lists them in the table of contents. To keep one section out of the table of contents, add `outlined: false` to its entry.
- An entry that is not a name and not a dictionary is content. The template makes a page of that content, without a title.

Read [Front Matter](REFERENCE.md#front-matter) for the full list of entries.

## Set the page numbers

By default, the numbers start on the first page of the body. The first number is the position of that page in the document. The cover and the front matter show no number. Two keys change this behavior:

| Key | Effect |
|-----|--------|
| `page.numbering-from` | The first page that prints a number. Give a position, or the label of an element on that page. |
| `page.numbering-start` | The number that this page prints |

```typst
page: (numbering-start: 1)                           // the body starts at 1
page: (numbering-from: 2)                            // page 2 prints 2, then 3, 4, ...
page: (numbering-from: 2, numbering-start: 3)        // page 2 prints 3, then 4, 5, ...
page: (numbering-from: <intro>, numbering-start: 1)  // the page of <intro> prints 1
```

A label is safer than a position, because a foreword that grows by one page does not move the label. The pages before the first numbered page print no number. The table of contents also shows no number for these pages. Read [Page Numbering](REFERENCE.md#page-numbering) for the details.

## Change the look

The `config` dictionary controls the look. Give only the keys you change. The other keys keep their default value. If you write an unknown key, the compilation stops, and the error message names the valid keys of that section.

```typst
#show: clean-cnam-template.with(config: (
  colors: (primary: rgb("#00539F"), secondary: auto),   // auto = derived from primary
  fonts: (title: (name: "Inter", weight: 700)),         // the weight comes from `default`
  page: (margin: (left: 2.5cm)),                        // the other margins do not move
  cover: (decorations: false, title: (size: 3em)),
  headings: (chapter-style: "plain"),                   // no chapter page
  outline: (depth: 2),
  print: true,                                          // no color and no underline on links
))
```

| Section | What it controls | Details |
|---------|------------------|---------|
| `info` | Title, subtitle, authors, class, dates, logo | [reference](REFERENCE.md#info----document-metadata-and-cover-content) |
| `colors` | Primary and secondary colors, outline, page numbers, neutral shades, math environments | [reference](REFERENCE.md#colors----semantic-palette) |
| `fonts` | Fonts of the text, the titles, the chapters, the code, and the base size | [reference](REFERENCE.md#fonts----typography) |
| `page` | Margins, numbering pattern, position of the number | [reference](REFERENCE.md#page----page-setup) |
| `cover` | Background, decorations, second logo, and one dictionary for each element | [reference](REFERENCE.md#cover-page-customization) |
| `code` | Accent color, background color, and one color for each language | [reference](REFERENCE.md#code----code-block-colors) |
| `render` | Functions that replace the cover, the decorations, the header, the footer, or the chapter page | [reference](REFERENCE.md#rendering-hooks) |
| `headings` | Style of the level-1 headings, page break, and the "Chapitre N" label | [reference](REFERENCE.md#headings----level-1-heading-rendering) |
| `outline` | Table of contents: on or off, custom content, indent, depth | [reference](REFERENCE.md#outline----table-of-contents) |
| `front-matter` | The pages between the cover and the body | [reference](REFERENCE.md#front-matter) |
| `lang`, `print`, `color-words` | Language, print mode, words in the primary color | [reference](REFERENCE.md#top-level-keys) |

### Themes and presets

A theme is a configuration layer under your own configuration. Your `config` always wins over a theme. To apply several themes, pass an array. The last layer wins:

```typst
#show: clean-cnam-template.with(
  theme: (presets.memoire, themes.sobre),
  config: (info: (title: "Mémoire")),
)
```

| Layer | Effect |
|-------|--------|
| `themes.cnam` | The default look, written in full |
| `themes.sobre` | No decorative circles, and a neutral text on the cover |
| `themes.dark` | A dark cover with white text |
| `themes.monochrome` | Gray shades, for a black and white print |
| `presets.article` | Short documents: no chapter page, no decorations, smaller margins |
| `presets.memoire` | A larger left margin for the binding, a two-level outline, a date range on the cover |
| `presets.tp` | Lab reports: 11pt text, small margins, no table of contents |

To write your own theme, write a dictionary. Read [Themes and Presets](REFERENCE.md#themes-and-presets).

## Read more

- [REFERENCE.md](REFERENCE.md) documents every key, every component parameter, and the advanced sections: cover, rendering hooks, print mode, heading variants, cross-references, code blocks.
- [CHANGELOG.md](CHANGELOG.md) lists the changes of each version.
- To work on the template itself, read [Development](REFERENCE.md#development).

## Author

- **Tom Planche**

## Acknowledgements

- [hzkonor/bubble-template](https://github.com/hzkonor/bubble-template), the first basis of this template.
- [Ives-Natsume/typst-endfield-doc-theme](https://github.com/Ives-Natsume/typst-endfield-doc-theme) by metasequoiaNI (MIT), the source of the style of the code blocks.
- [github-linguist/linguist](https://github.com/github-linguist/linguist) (MIT), the source of the colors in `code.lang-colors`.

## License

MIT
