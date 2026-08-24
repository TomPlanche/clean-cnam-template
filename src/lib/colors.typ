/**
 * Default colour palette for the template
 *
 * These values seed `config.colors`. Components never hardcode a shade: they read the
 * resolved palette from the config store, so swapping a value here (or overriding it in
 * `config.colors`) restyles every component at once.
 */

// Brand
#let cnam-red = rgb("#E94845")

// Neutral ramp, from lightest to darkest.
// The values match Typst's `luma()` shades the components used before the palette existed,
// so the default rendering is unchanged.
#let neutral-lightest = luma(250) // code block background
#let neutral-light = luma(230)    // block and blockquote background
#let neutral-border = luma(180)   // code block border
#let neutral = luma(170)          // blockquote accent, line numbers (Typst's `gray`)
#let neutral-dark = luma(100)     // blockquote attribution
#let neutral-darkest = luma(80)   // code block label bar

// Mathematical component colors
#let theorem-color = rgb("#800080")    // Purple - for theorems and demonstrations
#let example-color = rgb("#0000ff")    // Blue - for examples
#let definition-color = rgb("#ff0000") // Red - for definitions
