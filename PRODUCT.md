# Product

## Register

product

## Users

Judith and her friends, using their phones during pregames/parties — usually one person holding the phone while a group stands or sits around. Low light, some drinks already in, short attention spans between rounds. The job: keep a party game moving with zero setup friction (no accounts, no explanations needed beyond "tap the card").

## Product Purpose

A mobile party-game app built with Flutter. "Rojo Negro" deals cards one at a time from a shuffled 52-card poker deck; tapping the card advances to the next one, and the deck reshuffles ("EMPEZAR DE NUEVO") once exhausted. "Calimocho" is a drinking-game adaptation of the classic Juego de la Oca: a 63-square spiral board, players roll a die and hop a token square by square, and special squares (geese, bridge, well, jail, skull, goal...) trigger drink rules — it needs its own lightweight player setup (name + token color) scoped to that mode only, since the app otherwise has no persistent player list. The home screen is a menu of game modes — Rojo Negro and Calimocho are live; a third mode is still a placeholder ("PRONTO"). Success = a group can pick any mode up with zero explanation and keep playing without the app getting in the way.

## Brand Personality

Fiestera, atrevida, con chispa — party energy, a little cheeky, built for a group having a good time with drinks in hand. Confident and playful rather than polished-corporate; it should feel like a fun object passed around a table, not a productivity tool.

## Anti-references

Must not read as generic AI-generated UI: no identical uniform card grids, no gradient text, no decorative glassmorphism, no generic stock icon soup, no tiny uppercase tracked eyebrows above every section. Also avoid: cold corporate-SaaS polish, anything that feels like a casino-compliance app, and busy screens that slow down a drunk thumb trying to tap "next card."

## Design Principles

- One-thumb, one-glance: every screen must be operable with a single tap, readable at arm's length in dim bar/living-room light.
- Personality over polish: small surprising touches (motion, color, type character) beat generic SaaS-clean minimalism — this is a toy, not a tool.
- The card is the star: the game's single interactive object (the card) should always be the most visually dominant, confident element on screen.
- Fast and disposable: no screen should require explanation; a new player should understand what to do within one round just by watching.
- Restraint under energy: bold and fun, but never so busy it slows down gameplay or confuses at a glance.

## Accessibility & Inclusion

No formal WCAG target set; default to solid body-text contrast (≥4.5:1) since the app is used in dim, low-light party settings where legibility matters more than usual. Respect `prefers-reduced-motion` semantics conceptually (keep motion snappy and skippable, never gate content visibility behind an animation) even though Flutter's own reduce-motion signal isn't wired in yet.
