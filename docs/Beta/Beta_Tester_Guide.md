---
title: PlatePilot — Beta Tester Guide
version: 1.0
date: 2026-06-29
owner: Whitney (Docs) + Alice (Marketing) + Uma (CS)
audience: 50–100 recruited beta testers
window: 4 weeks
brand_ref: Docs/Brand/PlatePilot_BrandBook_v1.md
---

# Welcome to the PlatePilot Beta 🍽️

First — thank you. You're among the first 50 to 100 households to test PlatePilot before anyone else. Your feedback will shape the v1 millions of families will use. We're a small team, we read every word, and we won't judge you for the messiest pantry in the world. We designed this app for real life.

This guide will get you running in five minutes and explain what to test, what to report, and how to reach us. If anything is unclear, stop and ask — `feedback@platepilote.test`. There are no dumb questions; there are only undocumented ones.

---

## 1. Install PlatePilot

Pick your platform. All three builds host the *same* v0.9.0 code so we can compare notes.

- **iOS (TestFlight)** → `{{PLACEHOLDER_TESTFLIGHT_LINK}}`
- **Android (Firebase App Distribution)** → `{{PLACEHOLDER_FIREBASE_LINK}}`
- **Android (direct APK)** → `{{PLACEHOLDER_APK_LINK}}` *(for testers who hit Firebase auth issues)*

> If a link fails or your device is rejected, email `feedback@platepilote.test` with your device model + OS version. We'll add you manually within 24 hours.

---

## 2. Create your account

Open the app → **Create account** → enter your email + password (min. 8 chars) → confirm via the link we send.

No card required. No marketing emails. Your account is beta-locked for the four-week window.

---

## 3. Onboarding (under 60 seconds)

The first screen asks **four questions**, in this order:

1. Who's eating at home this week? *(household size — 1 to 6)*
2. What's your weekly grocery budget? *(slider, in €/CHF/CAD)*
3. Anything to avoid? *(allergens, diets, dislikes — free text)*
4. What's already in your pantry? *(type 3 to 5 staples — even rough guesses work)*

Then the app auto-generates your **first week** — seven dinners, one grocery list. No more steps. You're done.

> *Why so few questions? We want to test whether 60 seconds is realistic. If it doesn't feel real for you, that's exactly the feedback we need.*

---

## 4. Test Scenarios — 5 Personas

Try at least **one persona** that fits your real life. Run each action and note what feels right or clunky.

### 🩰 Sarah — Busy Professional (28, solo, late finishes)
- Set household to 1, budget €45/week, pantry nearly empty
- Generate a plan on Sunday night at 23:00
- Swap one meal you don't want
- Open the grocery list offline (airplane mode)
- Mark one meal "not cooked" — see what the app says back

### 👨‍👩‍👧‍👦 Mark & Julia — Parents of two (Lyon)
- Set household to 4, budget €120/week, kids "no mushrooms, no fish"
- Generate a full week
- Re-generate twice with the same inputs — is it varied?
- Use the grocery list on a real Saturday shop
- Save one recipe as favourite — find it again next week

### 🏋️ Alex — Fitness-conscious (track protein, batches on Sundays)
- Set budget €60/week, pantry heavy on chicken, oats, eggs
- Generate plan, check estimated protein per meal
- Skip two meals → regenerate the rest of the week
- Mark 3 pantry staples as "always have" — see if they persist

### 🎓 Emily — Student (budget tight, eats mostly dry staples)
- Set household to 1, budget €25/week, pantry = pasta, lentils, canned tomatoes
- Generate plan — is it realistic?
- Try the budget alert at 80 % spent
- Use the in-app link to send feedback

### 🛠️ Admin / Power-User (you like breaking things)
- Try entering impossible budgets (€5/week for 4 people)
- Try allergens you've never heard of (we expect weird inputs)
- Force-quit the app during plan generation
- Try the same action 10 times rapidly (buttons should not double-fire)

---

## 5. What to Report

Two channels, your choice.

| Channel | Use it when… |
|---|---|
| **In-app survey** *(Profile → Send feedback)* | You hit a bug, a friction, or a "wow" moment — takes 60 s |
| **Email** `feedback@platepilote.test` | You need to attach a screenshot, video, or longer story |

**What we want to hear (the good, the bad, the ugly):**
- 🐛 **Bugs** — crashes, broken screens, weird data
- 🧱 **Friction** — anything that took longer than expected or made you sigh
- 🤔 **Confusion** — copy you didn't understand, labels you misread
- ✨ **Delight** — moments you showed someone or screens you'd send a friend

> *Honest > positive. "I almost gave up at step 3" is more useful than "everything is fine".*

---

## 6. Closing In — 4 Weeks

The beta closes on **`{{PLACEHOLDER_BETA_END_DATE}}`**. After that:
- You'll keep Pro free for **6 months** as thanks
- Your launch price is locked
- Your account + data can be exported or deleted in one click

Thank you for trusting us with your weeknights. See you inside. 🧡

— *The PlatePilot team*
