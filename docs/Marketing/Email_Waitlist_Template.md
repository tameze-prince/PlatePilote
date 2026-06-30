---
title: PlatePilot — Waitlist Confirmation Email
version: 1.0
date: 2026-06-29
owner: Alice (Marketing) + Whitney (Docs)
trigger: Subscribe form submit on landing page
audience: 50–100 signups during beta campaign
brand_ref: Docs/Brand/PlatePilot_BrandBook_v1.md
type: HTML + Markdown render-ready
---

# Waitlist Confirmation Email

---

## Subject line (≤ 60 char)

You're in 🍽️ Confirm your PlatePilot beta seat (60 seconds)

**Variante A (chaleureux)** : `Bienvenue dans la beta — on a gardé ta place 🧡`
**Variante B (direct)** : `Confirm your beta seat — link valid 7 days`

---

## Preheader (≤ 90 char)

Tap once to lock your seat among the 100 beta households shaping PlatePilot's first version.

---

## Body — Markdown (≈ 200 mots)

```markdown
Hey {{first_name}} 👋

You're officially on the PlatePilot beta waitlist.

A few hundred households asked for a seat — you're one of the **first 100** who get to shape the version millions of families will cook with later this year.

**One quick thing.** Tap the button below within **7 days** to lock your seat. After that, we'll offer it to the next household.

[ 🍽️ Confirm your beta tester seat ]   ←  CTA bouton coral #FF7A59

Once confirmed, you'll receive:
- a TestFlight or Firebase link within **24 hours** (your device, your choice)
- a 5-minute install guide (already attached)
- a direct line to `feedback@platepilote.test` — yes, a human reads it

**The beta runs for 4 weeks.** Pantry, budget, week. You'll test the meal planner, the auto-grocery list, and the budget tracker — and you'll get **Pro free for 6 months** as thanks.

We built PlatePilot because we were tired of the 6 p.m. question. Thanks for helping us answer it.

À dimanche,
— *The PlatePilot team*

P.S. Your data never leaves the EU. Delete your account anytime in two clicks. Privacy policy → {{PLACEHOLDER_PRIVACY_LINK}}
```

---

## CTA spec (HTML)

```html
<table role="presentation" cellpadding="0" cellspacing="0" border="0">
  <tr>
    <td align="center" bgcolor="#FF7A59" style="border-radius:8px;">
      <a href="{{PLACEHOLDER_CONFIRM_LINK}}"
         style="display:inline-block; padding:16px 32px; color:#FFFBF7;
                font-family:Inter,Arial,sans-serif; font-size:16px;
                font-weight:600; text-decoration:none;">
        Confirm your beta tester seat →
      </a>
    </td>
  </tr>
</table>
```

---

## Design tokens (inline)

| Token | Value | Usage |
|---|---|---|
| Background page | `#FFFBF7` (paperWhite) | email body background |
| Primary button | `#FF7A59` (coral sunset) | CTA confirmation |
| Border radius | `8px` | CTA pill rounding |
| Display font (only headers) | Plus Jakarta Sans 700 | H1 in hero, fallback sans-serif |
| Body font | Inter 400/500/600 | everything else |
| Footer text color | `#1F2937` navy deep | legal block |
| Footer link color | `#FF7A59` (coral) | unsubscribe + privacy |

---

## Footer (always present)

```
PlatePilot SAS · Paris · hello@platepilote.app
You're receiving this because you joined the PlatePilot waitlist at platepilote.app.
Unsubscribe · Update preferences · Privacy policy · RGPD commit
```

---

## Send & test checklist

- [ ] From name : `PlatePilot — Équipe beta`
- [ ] From email : `beta@platepilote.app` *(or current transactional sender)*
- [ ] Reply-to : `feedback@platepilote.test` *(human inbox, monitored)*
- [ ] List-Unsubscribe header present (RGPD)
- [ ] Test render : Gmail (web + mobile) · Outlook · Apple Mail · iOS Gmail app
- [ ] A/B : subject A (warm) vs subject B (direct) — winner rotates after 48 h
- [ ] Confirmation window : 7 days (after that, seat re-released + gentle re-engagement email)
