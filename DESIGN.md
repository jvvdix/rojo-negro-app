---
name: Baraja Party — Rojo Negro
description: A pocket-sized party-game deck for late-night rounds with friends.
colors:
  ember: "#E0293B"
  oxblood: "#7A0F1E"
  whiskey-gold: "#E0B84A"
  blackout: "#0E0E11"
  ash-charcoal: "#1B1B20"
  ash-charcoal-raised: "#26262E"
  paper: "#FFFFFF"
  table-black: "#1A1A1A"
  token-teal: "#3FA79A"
  token-sky: "#3E93B8"
  token-denim: "#4C7FD1"
  token-indigo: "#6C6FD8"
  token-violet: "#8B6FDB"
  token-orchid: "#A96FCB"
  token-mauve: "#B96FA8"
  token-sage: "#6E8F63"
typography:
  display:
    fontFamily: "Anton, Roboto, sans-serif"
    fontSize: "26px"
    fontWeight: 400
    lineHeight: 1.0
    letterSpacing: "0.02em"
  headline:
    fontFamily: "Anton, Roboto, sans-serif"
    fontSize: "22px"
    fontWeight: 400
    lineHeight: 1.05
    letterSpacing: "0.01em"
  title:
    fontFamily: "Roboto, sans-serif"
    fontSize: "19px"
    fontWeight: 800
    lineHeight: 1.1
    letterSpacing: "0.01em"
  body:
    fontFamily: "Roboto, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.4
  label:
    fontFamily: "Roboto, sans-serif"
    fontSize: "12px"
    fontWeight: 700
    letterSpacing: "0.05em"
rounded:
  sm: "14px"
  md: "16px"
  lg: "24px"
spacing:
  xs: "8px"
  sm: "12px"
  md: "16px"
  lg: "20px"
  xl: "28px"
components:
  button-primary:
    backgroundColor: "{colors.ember}"
    textColor: "{colors.paper}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "18px 24px"
  mode-card-active:
    backgroundColor: "{colors.ember}"
    textColor: "{colors.paper}"
    typography: "{typography.title}"
    rounded: "{rounded.lg}"
    padding: "22px 20px"
  mode-card-disabled:
    backgroundColor: "{colors.ash-charcoal}"
    textColor: "{colors.paper}"
    typography: "{typography.title}"
    rounded: "{rounded.lg}"
    padding: "22px 20px"
  playing-card:
    backgroundColor: "{colors.paper}"
    textColor: "{colors.table-black}"
    rounded: "{rounded.lg}"
  oca-cell:
    backgroundColor: "{colors.ash-charcoal}"
    rounded: "{rounded.sm}"
  oca-cell-goal:
    backgroundColor: "{colors.whiskey-gold}"
    rounded: "{rounded.sm}"
  oca-token:
    textColor: "{colors.paper}"
---

# Design System: Baraja Party — Rojo Negro

## 1. Overview

**Creative North Star: "Last Call"**

The hour when the lights are low, the music's louder than it should be, and someone just yelled "one more round." Baraja Party lives entirely in that moment: a near-black room lit mostly by one warm ember-red glow, a single white card doing all the talking. It's fiestera, atrevida, con chispa — party energy with a bit of mischief, built to be passed hand to hand around a table, never held by one person reading a manual.

This system explicitly rejects the generic-AI tell set: no identical card grids pretending to be a dashboard, no gradient text, no decorative glassmorphism, no stock-icon soup, no tiny tracked-uppercase eyebrows sitting above every section pretending to be editorial. It also rejects the opposite failure mode — cold casino-compliance sterility. This is a toy, not a tool, and it should look like one: heavy, condensed display type with attitude; one saturated color doing almost all the emotional work; every tap answered with a small physical snap, like flicking a real card across felt.

**Key Characteristics:**
- One dominant saturated color (ember red) against a near-black "blackout" field — never a rainbow, never washed-out pastel.
- A heavy condensed display face (Anton) for anything shouted (titles, mode names, buttons); a clean grotesque (Roboto) for anything read (hints, descriptions).
- The playing card is always the single largest, highest-contrast object on any game screen.
- Every interactive object responds physically to touch — a quick compress-and-release, not a static color swap.

## 2. Colors

A one-accent system: blackout and ash-charcoal carry the whole room, ember carries all the energy, whiskey-gold is struck like a match only for rare, specific moments.

### Primary
- **Ember** (#E0293B): The one saturated color in the system. Carries the active game mode, primary buttons, and the red suits on the card face. Used deliberately, never diluted with a second competing hue.
- **Oxblood** (#7A0F1E): Ember's shadow-side twin, used only in the two-stop gradient that gives the active mode tile and pressed states their depth. Never used flat on its own.

### Secondary
- **Whiskey Gold** (#E0B84A): Reserved for delight — the "Pronto" hourglass, a rare highlight glint, a win-state flourish. If gold shows up on more than one element per screen, it's being overused.

### Neutral
- **Blackout** (#0E0E11): The base "felt" — every screen's background. Reads as a dim room, not a design-system gray.
- **Ash Charcoal** (#1B1B20): The resting state for inactive containers — the status pill, disabled mode tiles, sheet backgrounds. One step off blackout, not a jump.
- **Ash Charcoal Raised** (#26262E): Reserved for pressed/hover states on dark surfaces — a visible but subtle lift, never a full color change.
- **Paper** (#FFFFFF): The playing card's face and all primary text on dark surfaces. The single brightest thing allowed on screen besides ember.
- **Table Black** (#1A1A1A): Ink color for black suits and rank labels printed on the white card face — never used as a UI background; it's ink, not felt.

### Token Palette (utility exception)
- **Teal** (#3FA79A), **Sky** (#3E93B8), **Denim** (#4C7FD1), **Indigo** (#6C6FD8), **Violet** (#8B6FDB), **Orchid** (#A96FCB), **Mauve** (#B96FA8), **Sage** (#6E8F63): eight cool, desaturated tones used *exclusively* to tell player tokens apart on the Calimocho board. Deliberately excludes red/orange/gold so no token ever competes with ember or whiskey-gold for "the" accent. Never used as fills, buttons, or backgrounds — token identity only, and always paired with the player's initial (color is never the only signal).

### Named Rules
**The One-Ember Rule.** Only one saturated color is allowed to dominate a screen at a time: ember red. Whiskey gold may appear once, small, and only when it's earning a moment of delight — never as a second competing accent. The Token Palette is the one explicit, scoped exception: it identifies people, not brand — ember still owns the "pay attention here" job via a glow ring around whoever's turn it is.

## 3. Typography

**Display Font:** Anton (with Roboto, sans-serif fallback)
**Body Font:** Roboto (system default, with sans-serif fallback)

**Character:** Anton is a heavy, condensed, all-caps-friendly grotesque with real shout in it — used anywhere the app is "talking loud" (titles, mode names, button labels). Roboto stays underneath for anything meant to be read calmly (hints, descriptions, helper text), so the contrast between the two carries the app's own contrast between energy and clarity.

### Hierarchy
- **Display** (400, 26px, line-height 1.0, Anton): AppBar titles ("ROJO O NEGRO", "BARAJA PARTY").
- **Headline** (400, 22px, line-height 1.05, Anton): The home screen's "Elige tu modo de juego" headline.
- **Title** (800, 19px, line-height 1.1, Roboto): Mode card names, button labels ("EMPEZAR DE NUEVO").
- **Body** (400, 14px, line-height 1.4, Roboto): Mode card subtitles, descriptions, sheet copy.
- **Label** (700, 12px, letter-spacing 0.05em, uppercase, Roboto): Status pill text ("MAZO: 32"), the "PRONTO" badge, hint captions.

### Named Rules
**The Shout/Talk Rule.** Anton is for shouting (titles, names, CTAs); Roboto is for talking (context, hints). Never swap them — a hint set in Anton reads as noise, a title set in Roboto reads as flat.

## 4. Elevation

Flat "felt" at rest, lifted only where a hand can touch it. Blackout and ash-charcoal never cast shadows on each other — depth exists only around the two interactive object families: mode cards and the playing card itself. Both use a soft, warm-black diffuse shadow (never a hard drop shadow) to read as objects resting just above the felt, not stuck to it.

### Shadow Vocabulary
- **card-float** (`box-shadow: 0 10px 24px rgba(0,0,0,0.5)`): The default resting shadow under the playing card and mode tiles.
- **card-pressed** (`box-shadow: 0 4px 12px rgba(0,0,0,0.35)`): Shadow shrinks and tightens on press, reinforcing the compress-down tactile response.
- **ember-glow** (`box-shadow: 0 0 22px rgba(224,41,59,0.45)`): A rare, warm glow used only behind the active mode's icon chip and on primary-button press release — the "match strike" moment, not a default state.

### Named Rules
**The Felt Rule.** Static surfaces (backgrounds, status pills, disabled tiles) are flat. Only things a thumb can act on are ever allowed a shadow.

## 5. Components

### Buttons
- **Shape:** 16px corner radius, full-width by default.
- **Primary:** Ember background, paper text, Roboto Title weight (800), uppercase, 18px vertical padding. On press: scales to 0.96 with a quick ease-out-quart, shadow tightens from card-float to card-pressed, then springs back to 1.0 on release (never a linear tween — it should overshoot slightly, like a real card snap).
- **Disabled/empty states:** N/A today — the deck's "EMPEZAR DE NUEVO" only ever renders when actionable.

### Mode Cards (signature component)
- **Corner Style:** 24px radius, larger than buttons — these are the "big" objects on the home screen.
- **Active (Rojo o Negro, Calimocho):** Ember→Oxblood diagonal gradient, ember-glow shadow on its icon chip, paper text, forward chevron.
- **Disabled (Modo 3):** Flat ash-charcoal fill (no gradient — gradients are reserved for what's actually playable), 55% opacity, a small "PRONTO" pill in whiskey-gold-tinted ash-charcoal-raised.
- **Press feedback:** Same compress-and-release as buttons; disabled cards still compress slightly on tap even though they open the Coming Soon sheet, so the whole home screen feels alive under a thumb.

### Oca Board (signature component, Calimocho)
- **Layout:** 7×9 rectangular inward spiral, 63 cells, sized at runtime to fit the screen without scrolling — never a fixed pixel grid.
- **Cells:** Flat ash-charcoal, quiet by default; special squares differentiated by a single emoji glyph, never by a rainbow of fills (the board is one component, not 63 little cards). The goal cell (63) is the only cell allowed a whiskey-gold tint.
- **Tokens:** A Token Palette circle + the player's initial, always both together. The current player's token wears an ember glow ring — the board's one deliberate reuse of "ember means look here."
- **Movement:** Dice rolls hop the token one cell at a time with a small vertical bounce per hop, tracing the spiral. Teleports (bridge/labyrinth/skull) use a distinct vanish/reappear treatment — never a hop across intervening cells.

### Dice (Calimocho)
- **Style:** Paper-white rounded square, table-black pips — same ink-on-paper language as the playing card, not a separate material.
- **Interaction:** Tap-to-roll with a brief cycling-faces shuffle before settling; disabled (40% opacity, inert) whenever it isn't a rollable player's turn.

### Playing Card (signature component)
- **Corner Style:** 24px radius, paper background, card-float shadow.
- **Ink:** Table Black for spades/clubs, Ember for hearts/diamonds — full-size suit glyph centered, rank+suit mirrored in opposite corners.
- **Interaction:** The card itself is the primary control — tapping it is how the game advances. On tap: a quick compress (scale 0.97) before the next card slides in from the right with a fade; this is the single most-repeated gesture in the app and must feel the most satisfying.
- **Card Change:** Incoming card slides in from the right, fading in, over the outgoing card's fade-out — no card ever appears face-down or flips; the deck always plays face up.

### Status Pill
- **Style:** Ash-charcoal fill, fully rounded ("pill"), centered label text, Label typography.
- **Role:** The only always-visible piece of UI chrome besides the card and its action — must never compete visually with the card.

### Bottom Sheet (Coming Soon)
- **Style:** Ash-charcoal background, 24px top corners only, whiskey-gold hourglass icon as the sole accent, primary button to dismiss.

## 6. Do's and Don'ts

### Do:
- **Do** let the playing card be the largest, highest-contrast object on every game screen — nothing else may match its visual weight.
- **Do** give every tappable object a physical compress-then-release response (scale 0.96–0.97, ease-out-quart in, slight spring back out).
- **Do** keep ember red as the only saturated color carrying real surface area; let whiskey-gold strike like a match, once, when it's earned.
- **Do** pair Anton (shouting) with Roboto (talking) — never use one where the other belongs.
- **Do** keep the Token Palette scoped to player identification only — never repurpose those colors as buttons, fills, or a second brand accent.

### Don't:
- **Don't** use identical uniform card grids, gradient text, decorative glassmorphism, or generic stock icons — the generic-AI tell set this system explicitly rejects.
- **Don't** add a tiny uppercase tracked eyebrow above sections "because landing pages do this" — this isn't a landing page.
- **Don't** let a second saturated color compete with ember on the same screen.
- **Don't** apply card-float or ember-glow shadows to static, non-interactive surfaces — shadows are earned by touch, not decoration.
- **Don't** flip the card face-down again or reintroduce a "guess red or black" mechanic — the deck plays face up, always; the only interaction is tapping it forward.
