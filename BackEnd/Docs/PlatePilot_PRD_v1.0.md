# PlatePilot MVP Product Requirements Document (PRD) v1.0

**Document Version:** 1.0  
**Date de création:** 12 May 2026  
**Statut:** In Progress - Validation Phase  
**Audience:** Product Team, Engineering Team, Design Team  
**Last Updated:** 12 May 2026

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Product Goals](#2-product-goals)
3. [Target Users](#3-target-users)
4. [Problem Statement](#4-problem-statement)
5. [Success Metrics](#5-success-metrics)
6. [MVP Scope](#6-mvp-scope)
7. [User Stories](#7-user-stories)
8. [Functional Requirements](#8-functional-requirements)
9. [Business Rules](#9-business-rules)
10. [User Flows](#10-user-flows)
11. [Non-Functional Requirements](#11-non-functional-requirements)
12. [Technical Considerations](#12-technical-considerations)
13. [Analytics Requirements](#13-analytics-requirements)
14. [Out of Scope](#14-out-of-scope)
15. [Release Plan](#15-release-plan)
16. [Open Questions](#16-open-questions)
17. [Appendices](#17-appendices)

---

## 1. Executive Summary

### 1.1 Product Overview

**PlatePilot MVP** is a mobile application that solves the recurring problem of meal planning and grocery shopping by automating both processes. The MVP focuses on delivering maximum value with minimal complexity through a streamlined onboarding process and intuitive three-screen interface.

### 1.2 Core Value Proposition

Users can create a personalized weekly meal plan and optimize their grocery list in **less than 60 seconds**, taking into account their dietary preferences, budget, available time, and existing kitchen inventory.

### 1.3 Key Differentiators

- **Radical Simplicity:** Onboarding completed in under 60 seconds with only essential setup questions
- **Intelligent Automation:** Automatic meal plan generation based on real constraints
- **Budget-First Approach:** Built-in budget management with real-time cost tracking
- **Pantry Awareness:** Prioritizes using existing ingredients to reduce waste
- **Mobile-Native Design:** Optimized for on-the-go usage

### 1.4 Business Model

**Freemium Model:**
- **Free Tier:** Basic meal planning (limited to 2 plans/month), simple grocery list, basic pantry
- **Premium Tier:** Unlimited meal planning, advanced pantry management, budget optimization, shared accounts

### 1.5 Target Launch Timeline

- **Phase 1 (Weeks 1-2):** Market Validation & User Research
- **Phase 2 (Weeks 3-4):** Wireframes & Design System
- **Phase 3 (Weeks 5-8):** MVP Development (Sprint-based)
- **Phase 4 (Weeks 9-10):** Beta Testing (Closed Beta with 50-100 users)
- **Phase 5 (Week 11+):** Public Launch

---

## 2. Product Goals

### 2.1 Primary Goals (MVP Phase)

#### Goal 1: Validate Market-Problem Fit
- **Objective:** Confirm that the meal planning + grocery shopping problem is sufficiently painful and recurring
- **Success Criteria:**
  - ≥ 100 survey responses
  - Average pain score ≥ 7/10
  - ≥ 50% of respondents report pain occurs weekly or more
  - ≥ 30% indicate willingness to pay

#### Goal 2: Achieve Rapid Onboarding
- **Objective:** Reduce time-to-value to under 60 seconds for first-time users
- **Success Criteria:**
  - 90% of users complete onboarding in <60 seconds
  - 95% of users reach their first meal plan within 2 minutes
  - Drop-off rate during onboarding <5%

#### Goal 3: Drive User Activation
- **Objective:** Get users to generate their first meal plan and grocery list
- **Success Criteria:**
  - ≥ 70% activation rate (onboarded users who create ≥1 plan)
  - ≥ 80% of activated users generate a grocery list
  - Average time from app install to first plan: ≤ 3 minutes

#### Goal 4: Demonstrate Value Retention
- **Objective:** Show that users return to use PlatePilot for subsequent meal planning
- **Success Criteria:**
  - Day-1 Retention ≥ 40%
  - Day-7 Retention ≥ 25%
  - ≥ 15% of users return for a second plan within 7 days

#### Goal 5: Build Foundation for Monetization
- **Objective:** Validate that users are willing to pay for premium features
- **Success Criteria:**
  - ≥ 5% conversion to Premium in beta (target: 10% at scale)
  - Average session value tracking enabled
  - Freemium conversion funnel documented

### 2.2 Secondary Goals (MVP Phase)

- Establish brand identity and market positioning
- Build initial waitlist (target: 500+ emails)
- Create content strategy for organic growth
- Document technical architecture for future scaling
- Establish baseline analytics and KPI infrastructure

---

## 3. Target Users

### 3.1 Primary Personas (MVP Focus)

#### Persona 1: Sarah - The Busy Professional
- **Age:** 28–35 years old
- **Situation:** Works 45+ hours/week, lives in urban area, limited cooking time
- **Motivation:** Save time, eat healthier, reduce delivery app spending
- **Pain Points:** Doesn't want to spend >10 minutes planning; too many app choices
- **Behavior:** Tech-savvy, appreciates automation, values efficiency
- **Device:** Primary iOS/Android user, uses apps daily
- **Budget Willingness:** High; willing to pay for time-saving tools

#### Persona 2: Mark & Julia - Young Parents
- **Age:** 35–42 years old
- **Situation:** 2 children, dual income, suburban lifestyle, varied scheduling
- **Motivation:** Manage family preferences/allergies, stick to budget, reduce food waste
- **Pain Points:** Complexity of current solutions, children's preferences hard to accommodate
- **Behavior:** Organized, value collaboration, appreciate shared features
- **Device:** Both use smartphones; need cross-device sync
- **Budget Willingness:** High; willing to subscribe for family planning tools

#### Persona 3: Alex - Fitness-Conscious Professional
- **Age:** 24–30 years old
- **Situation:** Active lifestyle, health-conscious, values optimization
- **Motivation:** Align meals with fitness goals, automate meal planning, track costs
- **Pain Points:** Difficulty balancing macros with real-world constraints; app fragmentation
- **Behavior:** Data-driven, appreciates metrics, likes personalization
- **Device:** High adoption of fitness apps; premium subscriber mindset
- **Budget Willingness:** Medium-High; willing to pay for specialized features

#### Persona 4: Emily - Student/Young Professional on Budget
- **Age:** 20–26 years old
- **Situation:** Limited budget, possibly in shared housing, new to cooking
- **Motivation:** Stay within strict budget, reduce waste, cook simple meals
- **Pain Points:** Apps ignore local pricing, overwhelming recipe options, unclear costs
- **Behavior:** Price-sensitive, appreciates simplicity, prefers free or low-cost tools
- **Device:** Smartphone-primary, occasional web usage
- **Budget Willingness:** Low; needs strong free tier value

### 3.2 Secondary Personas (Future Consideration)

- Solo home cooks focused on health optimization
- Families with dietary restrictions/allergies
- Meal-prep enthusiasts and batch cookers

### 3.3 User Segmentation

| Segment | Size Est. | Willingness to Pay | Primary Use Case |
|---------|-----------|-------------------|------------------|
| Busy Professionals | 35% | High | Quick planning, time-saving |
| Young Parents | 25% | High | Family coordination, budget control |
| Health-Conscious | 20% | Medium-High | Macro optimization, planning |
| Budget-Conscious Students | 20% | Low-Medium | Cost minimization, anti-waste |

---

## 4. Problem Statement

### 4.1 The Core Problem

Every week, millions of people face the same recurring decision-making burden:

1. **"What should I cook this week?"**
   - Causes mental fatigue and decision paralysis
   - Leads to repetitive meal choices
   - Often results in unhealthy alternatives (takeout, processed foods)

2. **"What do I need to buy?"**
   - Creates disorganized shopping lists
   - Results in forgotten items
   - Causes duplicate purchases of items already at home

3. **"Can I stick to my budget?"**
   - Difficulty predicting weekly food spend
   - Lack of visibility into cost per meal
   - No guidance on cost optimization

4. **"What do I already have at home?"**
   - Forgotten or poorly managed inventory
   - Wasted food due to spoilage
   - Inefficient use of existing ingredients

### 4.2 Quantified Impact

**Time Cost:**
- Average weekly planning time: 30–60 minutes
- Shopping list organization time: 15–30 minutes
- **Total:** 45–90 minutes/week × 52 weeks = 39–78 hours/year

**Financial Cost:**
- Average food waste per household: 15–20% of grocery spend
- Impulse purchases from disorganized shopping: 10–15% of budget
- Unnecessary takeout due to "no plan" stress: £200–400/month for some users

**Psychological Cost:**
- Weekly stress and mental load
- Sense of being disorganized
- Decision fatigue affecting other life areas

### 4.3 Why Existing Solutions Fall Short

| Solution | Strength | Critical Weakness |
|----------|----------|-------------------|
| Mealime | Good meal planning | Doesn't respect existing pantry; no budget integration |
| AnyList | Excellent shopping list | No automatic meal planning; manual heavy lifting |
| Eat This Much | Good nutrition optimization | Rigid plans; poor budget awareness; steep learning curve |
| Samsung Food | Well-designed app | Fragmented features; doesn't combine all pain points |
| Paprika | Good recipe management | Manual, time-intensive; not automated |

**Common Failings Across All:**
- Onboarding takes 5–15 minutes (not <60 seconds)
- Require too much manual input
- Don't intelligently combine budget + time + preferences + pantry
- Offer too many features (feature bloat vs. focused value)
- Poor or missing pantry management

### 4.4 Problem Validation Status

- ✅ Problem identified through user research
- 🔄 Validation in progress via online survey (target: 100+ responses)
- 🔄 Interviews scheduled with target personas
- ⏳ Competitive landscape analysis documented

---

## 5. Success Metrics

### 5.1 Product Metrics (North Star)

#### Primary Metric: Weekly Active Users (WAU)
- **Definition:** Number of unique users who generate ≥1 meal plan in a 7-day period
- **Target at 3 months:** 100 active users (beta)
- **Target at 6 months:** 500 active users
- **Target at 12 months:** 2,000+ active users

#### Secondary Metric: Activation Rate
- **Definition:** % of installed users who complete onboarding AND generate ≥1 meal plan
- **Target:** ≥ 70% (beta phase)
- **Tracking:** Measured from install through first plan generation

#### Tertiary Metric: Retention Curve
- **Day-1 Retention (D1):** ≥ 40%
- **Day-7 Retention (D7):** ≥ 25%
- **Day-30 Retention (D30):** ≥ 15%
- **Definition:** % of Day-0 users who return and generate ≥1 plan

#### Feature Adoption Metrics
- **Pantry Adoption:** ≥ 40% of activated users create ≥1 pantry entry
- **Grocery List Usage:** ≥ 80% of meal plan users export/view grocery list
- **Quick Meal Mode:** ≥ 20% of users use "Quick Meal" feature in first 7 days

### 5.2 Engagement Metrics

| Metric | Definition | Target |
|--------|-----------|--------|
| Session Frequency | Avg sessions per active user per week | ≥ 2.0 sessions/week |
| Session Duration | Avg time spent per session | 3–8 minutes |
| Time to First Plan | Avg time from install to first plan | ≤ 3 minutes |
| Plan Generation Frequency | Avg plans created per user per month | ≥ 2 plans |
| Feature Interaction Rate | % of users who interact with ≥3 distinct features | ≥ 60% |

### 5.3 Retention & Churn Metrics

| Metric | Definition | Target |
|--------|-----------|--------|
| Churn Rate (Monthly) | % of active users who don't return in 30 days | ≤ 20% |
| Return User Rate | % of users who come back for 2nd+ plan | ≥ 40% |
| Repeat Usage Frequency | Avg # of repeat sessions (beyond 1st plan) | ≥ 3 sessions |
| User Lifetime (Est.) | Expected weeks until churn | ≥ 12 weeks |

### 5.4 Conversion & Monetization Metrics

| Metric | Definition | Target (Beta) |
|--------|-----------|--------------|
| Free-to-Premium Conversion | % of free users converting to Premium | ≥ 5% |
| Time to Conversion | Avg days from activation to Premium sub | 7–14 days |
| Premium User Retention | % of Premium users retained at 30 days | ≥ 70% |
| Average Revenue Per User (ARPU) | Monthly revenue ÷ active users | Baseline by Month 2 |
| Lifetime Value (LTV) | Avg revenue generated per user | Estimated by Month 3 |

### 5.5 Quality Metrics

| Metric | Definition | Target |
|--------|-----------|--------|
| App Store Rating | Avg user rating | ≥ 4.2/5.0 stars |
| Crash Rate | % of sessions ending in crash | ≤ 0.5% |
| API Error Rate | % of API requests failing | ≤ 2% |
| Core Feature Success Rate | % of meal plan generation requests succeeding | ≥ 99% |
| Onboarding Completion Rate | % of users completing full onboarding | ≥ 95% |

### 5.6 User Satisfaction Metrics

| Metric | Definition | Target |
|--------|-----------|--------|
| Net Promoter Score (NPS) | Likelihood to recommend (0–10 scale) | ≥ 40 (beta), ≥ 50 (launch) |
| Customer Satisfaction (CSAT) | Satisfaction with meal plan quality (1–5) | ≥ 4.0 |
| Feature Satisfaction | Satisfaction with specific features | ≥ 4.0 per feature |
| Perceived Value Score | "App saves me time" (1–5 scale) | ≥ 4.2 |

### 5.7 Onboarding-Specific Metrics

| Metric | Definition | Target |
|--------|-----------|--------|
| Step Completion Rate (by step) | % completing each onboarding step | ≥ 95% per step |
| Total Onboarding Time | Avg time from Step 1 to Step completion | ≤ 60 seconds |
| Drop-off by Step | Identify where users abandon | < 5% per step |
| Return to Onboarding Rate | % who drop-off but return | ≥ 20% return within 7 days |
| First Plan Success Rate | % of users successfully creating plan on 1st attempt | ≥ 85% |

### 5.8 Analytics Instrumentation

All metrics will be tracked via:
- **Mobile Analytics:** Firebase/Amplitude (events, funnels, cohort analysis)
- **Backend Logging:** Cloud Watch (API performance, errors, latency)
- **Custom Dashboard:** Real-time metrics dashboard for product team
- **Weekly Reporting:** Automated metrics report to stakeholders

---

## 6. MVP Scope

### 6.1 Feature Breakdown

#### 6.1.1 MUST HAVE (Critical Path)

**Onboarding Flow**
- ✅ Welcome screen with app value prop (15 seconds)
- ✅ Quick preferences questionnaire (30–40 seconds)
  - Number of people to cook for
  - Dietary preferences/restrictions
  - Weekly budget (optional, can skip)
  - Available cooking time (simple: <30min, 30–60min, >60min)
  - Allergies (simple checkbox list: nuts, dairy, gluten, shellfish)
- ✅ Create account (email/password or social login)
- ✅ Permission requests (notifications, optional camera for pantry scan)
- ✅ Sample meal plan auto-generation on completion

**Home / Plan Screen**
- ✅ "Plan This Week" primary CTA button
- ✅ Display generated 7-day meal plan (visual card layout)
- ✅ Show budget estimate (if budget set)
- ✅ Quick filters: "Faster" / "Healthier" / "Cheaper" (adjust plan in-place)
- ✅ Ability to tap meal to swap with alternative (quick-replace)
- ✅ "View Grocery List" CTA

**Grocery List Screen**
- ✅ Auto-generated list from meal plan
- ✅ Organized by category (Vegetables, Proteins, Dairy, Pantry, etc.)
- ✅ Quantity and unit display
- ✅ Check-off functionality for items
- ✅ Total estimated cost calculation
- ✅ Export to text / copy-to-clipboard
- ✅ Share via link or native share

**Pantry Screen**
- ✅ Simple inventory input (manual text entry + bulk paste)
- ✅ Ingredients persist across plans
- ✅ Ability to mark item as "will use soon" (prioritize in planning)
- ✅ Ability to remove items
- ✅ Display "Inventory Used" on plan (highlight ingredients from pantry)
- ✅ Basic search/filter

**Authentication & Account**
- ✅ Email/password registration
- ✅ Social login (Google, Apple)
- ✅ Password reset flow
- ✅ Session management with JWT tokens
- ✅ Basic user profile (name, preferences, budget)

**Settings**
- ✅ Edit user preferences (dietary, budget, time)
- ✅ Manage allergies/restrictions
- ✅ Push notification toggle
- ✅ App version / support contact
- ✅ Logout

#### 6.1.2 SHOULD HAVE (High Priority, Post-MVP Nice-to-Have)

- 🔄 "Quick Meal" mode (15-min recipes when plan not used)
- 🔄 Basic recipe view with ingredients & instructions
- 🔄 Meal swap suggestions (same category, similar time/cost)
- 🔄 Simple notifications (plan reminder, expiring items in pantry)
- 🔄 Basic in-app help/tutorial

#### 6.1.3 NICE TO HAVE (Future - Out of MVP Scope)

- ⏳ Family/couple account sharing
- ⏳ Advanced pantry (barcode scanning, expiration dates)
- ⏳ Macro/calorie tracking
- ⏳ E-commerce integration (click-to-buy from grocery list)
- ⏳ Recipe ratings and favorites
- ⏳ Social features (share plans, community)
- ⏳ Voice assistant integration
- ⏳ Nutrition recommendations
- ⏳ Multi-language support (beyond English/French)

### 6.2 Detailed Feature Matrix

| Feature | MVP | Priority | Complexity | Estimated Dev Time |
|---------|-----|----------|------------|-------------------|
| Onboarding (<60s) | ✅ | P0 | Medium | 3–4 days |
| Home/Plan Screen | ✅ | P0 | Medium | 3–4 days |
| Grocery List Screen | ✅ | P0 | Medium | 3–4 days |
| Pantry Management | ✅ | P0 | Medium | 2–3 days |
| Authentication | ✅ | P0 | Medium | 2–3 days |
| Settings | ✅ | P1 | Low | 1–2 days |
| Quick Meal Mode | 🔄 | P1 | Medium | 2–3 days |
| Recipe Details | 🔄 | P1 | Low | 1–2 days |
| Notifications | 🔄 | P1 | Low | 1–2 days |
| Meal Swap Suggestions | 🔄 | P2 | High | 2–3 days |
| Analytics Integration | ✅ | P0 | Low | 1 day |
| Error Handling & Logging | ✅ | P0 | Medium | 2 days |

### 6.3 Content Scope

#### Recipe Database (MVP)
- **Minimum Size:** 150–200 base recipes
- **Meal Categories:** Breakfast, Lunch, Dinner, Snacks
- **Cooking Time:** Clearly labeled (<15min, 15–30min, 30–60min, >60min)
- **Difficulty:** Simple 3-tier system (Easy, Medium, Advanced)
- **Macro Info:** Calories, Protein, Carbs, Fats (for premium tier)
- **Ingredients:** Structured list with quantities, units, cost estimates

#### Ingredient Database (MVP)
- **Scope:** 500–800 common ingredients (by category)
- **Cost Data:** Regional pricing (UK, France, US base; expandable)
- **Allergen Flags:** Nuts, Dairy, Gluten, Shellfish, Soy, Eggs (extensible)
- **Categories:** Vegetables, Proteins, Dairy, Pantry, Frozen, Beverages

### 6.4 Non-Included Features

- ⛔ Shared family/couple accounts (post-MVP)
- ⛔ Barcode scanning (post-MVP)
- ⛔ Macro/calorie detailed tracking (post-MVP)
- ⛔ E-commerce integration (post-MVP)
- ⛔ Advanced pantry with expiration dates (post-MVP)
- ⛔ Community/social features (post-MVP)
- ⛔ Multi-language support beyond English (v1.1+)
- ⛔ Web app (mobile-only for MVP)
- ⛔ Offline mode (requires internet)

---

## 7. User Stories

### 7.1 Format & Convention

**Format:** As a [user role], I want to [action], so that [benefit]  
**Acceptance Criteria:** Clear, testable conditions for "done"

### 7.2 Onboarding & Authentication

#### US-001: User Creates Account
**Priority:** P0  
**As a** new user,  
**I want to** quickly create an account with minimal friction,  
**So that** I can start using PlatePilot immediately.

**Acceptance Criteria:**
- User can sign up via email/password OR social login (Google, Apple) in <30 seconds
- Email validation is enforced before account creation
- Social login auto-fills name (if available)
- User receives confirmation email (email-based signup only)
- User is logged in immediately upon successful signup
- User profile is created with default preferences
- Onboarding page appears immediately after signup

**Definition of Done:**
- UI component created and styled
- API endpoint for signup works
- Error handling for duplicate email, weak password
- Social login credentials configured
- Email verification flow working
- Analytics event fired on signup

---

#### US-002: User Logs Into Existing Account
**Priority:** P0  
**As a** returning user,  
**I want to** log in with my credentials,  
**So that** I can access my meal plans and pantry.

**Acceptance Criteria:**
- User can log in via email/password
- User can log in via social accounts (Google, Apple)
- Invalid credentials show clear error message
- Forgotten password flow available
- Session persists across app restarts (auto-login if token valid)
- User is directed to Home screen upon successful login
- Logout functionality available in Settings

**Definition of Done:**
- Login screen UI created
- JWT token management implemented
- Session validation on app startup
- Password reset email flow configured
- Social login integration tested
- Error handling for invalid credentials, network errors

---

#### US-003: User Completes Onboarding (First-Time Setup)
**Priority:** P0  
**As a** brand-new user,  
**I want to** quickly set my basic preferences,  
**So that** PlatePilot can generate personalized meal plans.

**Acceptance Criteria:**
- Onboarding completes in <60 seconds
- User answers questions about:
  - Number of people to cook for (1, 2, 3+)
  - Dietary preferences (Vegetarian, Vegan, Keto, Paleo, None)
  - Weekly cooking time availability (<30min, 30–60min, >60min)
  - Budget (optional; can skip)
  - Allergies (multi-select: Nuts, Dairy, Gluten, Shellfish, etc.)
- Preferences are saved to user profile
- User can skip optional questions (budget)
- Onboarding summary shows before completion
- User is taken to Home screen with first meal plan auto-generated
- "Skip" button available on optional steps

**Definition of Done:**
- Onboarding flow screens designed and implemented
- Form validation for required fields
- Preferences saved to database
- Default values set if optional fields skipped
- Analytics tracked for onboarding completion
- Test with <60 second timer

---

#### US-004: User Resets Forgotten Password
**Priority:** P1  
**As a** user who forgot their password,  
**I want to** reset it via email,  
**So that** I can regain access to my account.

**Acceptance Criteria:**
- "Forgot Password" link on login screen
- User enters email address
- Reset link sent to email (valid for 24 hours)
- Reset link takes user to password reset form
- User can set new password (minimum 8 characters)
- User is logged in automatically after reset
- Expired reset links show error message
- Old session tokens are invalidated

**Definition of Done:**
- Reset password UI screens created
- Email service integration (SendGrid/AWS SES)
- Token generation and validation logic
- Password reset endpoint secured
- Rate limiting on password reset requests
- Email template designed and tested

---

### 7.3 Meal Planning Features

#### US-005: User Generates Weekly Meal Plan
**Priority:** P0  
**As a** user,  
**I want to** automatically generate a 7-day meal plan,  
**So that** I don't have to spend time deciding what to cook each day.

**Acceptance Criteria:**
- "Plan This Week" button visible on Home screen
- One click generates a complete 7-day meal plan
- Generated plan respects user's:
  - Dietary preferences
  - Cooking time availability
  - Budget (if set)
  - Allergies
  - Number of people
- Existing pantry items are prioritized in plan
- Plan displays as visual cards (one per day)
- Each day shows: meal name, prep time, estimated cost
- User can view the plan immediately (no loading >3 seconds)
- Plan is saved automatically
- User can generate multiple plans (limited to 2/month on free tier)

**Acceptance Criteria (Technical):**
- Meal plan generation algorithm handles constraints
- Database query optimized for fast retrieval
- Plan data structure stored efficiently
- Edge cases handled: no valid recipes, budget too low, etc.

**Definition of Done:**
- Algorithm for meal plan generation documented
- UI component for plan display designed
- API endpoint for plan generation created
- Database schema for storing plans defined
- Error handling for generation failures
- Performance tested (generation time <3 seconds)
- Analytics event fired on plan generation

---

#### US-006: User Adjusts Meal Plan with Quick Filters
**Priority:** P1  
**As a** user,  
**I want to** quickly adjust the generated meal plan to be "Faster," "Healthier," or "Cheaper",  
**So that** I can get a plan that better matches my current needs.

**Acceptance Criteria:**
- Three filter buttons visible below generated plan: "Faster" / "Healthier" / "Cheaper"
- Tapping a filter re-generates plan with that priority
- Changes apply immediately (within 2 seconds)
- User can toggle filters on/off in sequence
- Original plan remains visible until filter applied
- Filters don't override core constraints (allergies, preferences)
- Each filter adjustment is tracked (analytics)

**Technical Acceptance Criteria:**
- Plan regeneration algorithm with priority weighting
- Efficient query to find alternative recipes by criteria
- Caching strategy for quick filter responsiveness

**Definition of Done:**
- Filter buttons UI designed
- Algorithm weights defined (time, health score, cost)
- Plan regeneration endpoint optimized
- Error handling for no matching recipes
- UX testing with sample users

---

#### US-007: User Swaps Individual Meal
**Priority:** P1  
**As a** user,  
**I want to** replace a single meal in my plan with an alternative,  
**So that** I can customize the plan without regenerating everything.

**Acceptance Criteria:**
- Tapping any meal card shows "Swap Meal" option
- Swap opens modal with 3–5 similar alternative recipes
- Alternatives respect same constraints (time, budget, allergies)
- User selects alternative meal
- Plan updates immediately
- Grocery list recalculates to reflect swap
- Undo functionality available (last 3 swaps)
- User cannot exceed max swaps (e.g., 5 per plan)

**Definition of Done:**
- Swap modal UI designed
- Recipe recommendation algorithm for alternatives
- Grocery list recalculation logic
- Undo stack implementation
- Analytics event on meal swap

---

#### US-008: User Views & Manages Grocery List
**Priority:** P0  
**As a** user,  
**I want to** view an organized, intelligent grocery list,  
**So that** I can shop efficiently without forgetting items.

**Acceptance Criteria:**
- Grocery list auto-generated from meal plan
- Items organized by category (Produce, Proteins, Dairy, Pantry, etc.)
- Pantry items marked as "already have" (not highlighted for purchase)
- Quantity and unit clearly displayed
- Total estimated cost shown at top
- Items can be checked off (visual feedback)
- Items can be added manually
- Items can be removed
- List can be exported as text
- List can be shared via link or native share (SMS, email, WhatsApp, etc.)
- Filter option to hide "already have" items
- Search functionality to find specific items

**Acceptance Criteria (Technical):**
- Grocery list generation optimizes for store layout (future: by store)
- Cost calculation accounts for ingredient pricing
- Pantry integration prevents duplicates
- Export format is clean and readable

**Definition of Done:**
- Grocery List screen UI designed
- List generation algorithm tested
- Cost calculation logic implemented
- Export/share functionality integrated
- UX tested for usability

---

### 7.4 Pantry Management

#### US-009: User Adds Items to Pantry
**Priority:** P0  
**As a** user,  
**I want to** record what ingredients I already have at home,  
**So that** PlatePilot can avoid suggesting recipes that require me to rebuy them.

**Acceptance Criteria:**
- "Add to Pantry" button accessible from Pantry screen
- User can:
  - Type ingredient name (autocomplete from ingredient database)
  - Specify quantity (optional)
  - Select unit (cups, grams, pieces, etc.)
- User can add multiple items in one session
- User can paste a bulk list of ingredients
- Items are saved immediately to pantry
- Pantry items display in sortable list
- User can search pantry items
- Added items persist across sessions

**Acceptance Criteria (Technical):**
- Pantry database schema supports quantity/unit
- Ingredient autocomplete pulls from database
- Bulk paste parsing handles common formats

**Definition of Done:**
- Pantry input UI designed
- Form validation for ingredient names
- Database operations for adding items
- Autocomplete implementation
- Test bulk import with sample data

---

#### US-010: User Removes Items from Pantry
**Priority:** P1  
**As a** user,  
**I want to** remove items from my pantry,  
**So that** my inventory stays current as I use ingredients.

**Acceptance Criteria:**
- Each pantry item has a delete/remove button (swipe or long-press)
- Confirmation dialog appears before deletion
- Deleted items are removed immediately
- Item removal doesn't affect past meal plans
- User can bulk-delete marked items
- Undo available for accidental deletions (within session)

**Definition of Done:**
- Delete UI interaction designed
- Confirmation dialog implemented
- Undo logic for session
- Analytics event on item removal

---

### 7.5 Settings & Account

#### US-011: User Updates Preferences
**Priority:** P1  
**As a** user,  
**I want to** update my dietary preferences and constraints,  
**So that** my meal plans stay relevant as my situation changes.

**Acceptance Criteria:**
- Settings screen accessible from Home
- User can update:
  - Number of people to cook for
  - Dietary preferences
  - Weekly budget
  - Cooking time availability
  - Allergies
- Changes saved immediately
- Next meal plan generated respects new preferences
- User receives confirmation that changes saved

**Definition of Done:**
- Settings UI designed
- Preference update endpoints
- Validation for updated values
- Analytics on preference changes

---

#### US-012: User Manages Notifications
**Priority:** P1  
**As a** user,  
**I want to** control which notifications I receive,  
**So that** I'm not overwhelmed by app messages.

**Acceptance Criteria:**
- Push notification toggle in Settings
- Option to enable/disable specific notification types:
  - Weekly plan reminders
  - Pantry expiration alerts (if applicable)
  - Tips and recommendations
- User preference saved locally and synced to backend
- Notifications respect user timezone

**Definition of Done:**
- Notification toggle UI
- Firebase Cloud Messaging setup
- Notification preference storage
- Local and remote configuration

---

#### US-013: User Logs Out
**Priority:** P0  
**As a** user,  
**I want to** log out of my account,  
**So that** my data is secure on shared devices.

**Acceptance Criteria:**
- Logout button visible in Settings
- Confirmation dialog appears before logout
- User session is cleared
- User is taken to login screen
- Cached data is cleared from device
- Auth token is invalidated on backend

**Definition of Done:**
- Logout UI button
- Session clearing logic
- Backend token invalidation
- Local data cleanup

---

### 7.6 Additional User Stories

#### US-014: User Views Quick Meal Suggestions (Nice-to-Have)
**Priority:** P2  
**As a** a busy user,  
**I want to** quickly find a recipe I can cook in <15 minutes,  
**So that** I can get an idea for dinner when my plan isn't available.

**Acceptance Criteria:**
- "Quick Meal" button accessible from Home screen
- Shows 3–5 recipes that can be prepared in <15 minutes
- Recipes respect dietary preferences and allergies
- User can view full recipe with ingredients/instructions
- User can add recipe to pantry for later or as a replacement

**Note:** This is POST-MVP but included as reference for future.

---

#### US-015: User Views Recipe Details
**Priority:** P2  
**As a** user,  
**I want to** see full recipe details (ingredients, instructions, nutrition),  
**So that** I know exactly how to prepare the meal.

**Acceptance Criteria:**
- Tapping a meal shows full recipe view
- Display: Title, servings, prep time, cook time, difficulty, instructions
- Ingredients list with quantities
- Nutrition facts (calories, protein, carbs, fats) if available
- User can scale recipe by servings (adjusts quantities)
- Back button returns to meal plan

**Note:** This is POST-MVP but included as reference.

---

## 8. Functional Requirements

### 8.1 Core Functional Requirements

#### 8.1.1 Meal Plan Generation Engine

**Requirement ID:** FR-001  
**Title:** Automatic Meal Plan Generation

**Description:**
The system must generate a 7-day meal plan based on user constraints and preferences with no manual recipe selection.

**Functional Specifications:**

1. **Input Parameters:**
   - Number of people (1, 2, 3+)
   - Dietary preferences (Vegetarian, Vegan, Keto, Paleo, None)
   - Cooking time availability (Low <30min, Medium 30-60min, High >60min)
   - Weekly budget (optional, in user's local currency)
   - Allergies (multi-select list)
   - Existing pantry items (list of ingredients)
   - Daily meals (Breakfast, Lunch, Dinner, Snacks - configurable)

2. **Processing Logic:**
   - Filter recipe database by:
     - Cooking time vs. availability
     - Dietary constraints (vegetarian, vegan, etc.)
     - Allergies (exclude any recipe with flagged allergens)
     - Ingredient availability (prioritize recipes using pantry items)
   - Apply budget constraint:
     - Calculate recipe cost based on ingredient pricing
     - Ensure total weekly cost ≤ user's budget (if set)
     - If impossible, recommend increasing budget or flag as "premium" plan
   - Optimize for variety:
     - Minimize recipe repetition within plan
     - Vary protein sources across week
     - Balance heavy/light meals
   - Handle edge cases:
     - If no recipes match criteria: suggest relaxing filters
     - If budget too restrictive: recommend increasing budget
     - If cooking time too limited: suggest batch cooking

3. **Output:**
   - Structured meal plan with:
     - Date
     - Meal type (Breakfast, Lunch, Dinner, Snack)
     - Recipe ID, name, servings
     - Estimated prep time, cook time
     - Estimated cost per meal
     - Ingredients list (with quantities)
   - Total estimated weekly cost
   - Pantry items used vs. items to purchase

4. **Performance Requirements:**
   - Generation must complete in <3 seconds
   - Support up to 1,000 concurrent generation requests
   - Database queries optimized with indexes

5. **Error Handling:**
   - If generation fails: show user-friendly error
   - Log failures for debugging
   - Fallback to basic plan if algorithm fails

---

#### 8.1.2 Grocery List Generation & Management

**Requirement ID:** FR-002  
**Title:** Intelligent Grocery List Generation

**Description:**
The system must generate an organized, cost-optimized grocery list from a meal plan.

**Functional Specifications:**

1. **List Generation:**
   - Aggregate all recipe ingredients for the week
   - Exclude items already in pantry (based on user's pantry list)
   - De-duplicate ingredients (combine quantities)
   - Organize by category (Produce, Proteins, Dairy, Pantry, Frozen, Beverages)
   - Calculate total cost
   - Flag items with cost data unavailable

2. **Data Structure:**
   ```
   GroceryList {
     id: UUID
     planId: UUID
     userId: UUID
     items: [{
       ingredientId: UUID
       name: String
       quantity: Float
       unit: String
       category: String
       estimatedCost: Float
       inPantry: Boolean
       checked: Boolean
     }]
     totalCost: Float
     createdAt: DateTime
     updatedAt: DateTime
   }
   ```

3. **Features:**
   - Users can check off items (visual feedback)
   - Users can add custom items (not from recipe)
   - Users can remove items
   - Users can modify quantities
   - Users can mark items "already have" (hide from shopping view)
   - Search/filter functionality
   - Export as text/CSV
   - Share via link or native share

4. **Cost Calculation:**
   - Use base ingredient pricing from database
   - Factor in regional pricing (if available)
   - Show per-item and total cost
   - Indicate when cost data unavailable
   - Budget comparison (total vs. user's budget)

5. **Persistence:**
   - List saved automatically when generated
   - List updates if meal plan modified
   - Users can manually edit and save changes

---

#### 8.1.3 Pantry Management System

**Requirement ID:** FR-003  
**Title:** User Pantry Inventory Management

**Description:**
The system must maintain a user's pantry inventory and use it to optimize meal planning and grocery lists.

**Functional Specifications:**

1. **Pantry Data Model:**
   ```
   PantryItem {
     id: UUID
     userId: UUID
     ingredientId: UUID
     ingredientName: String
     quantity: Float
     unit: String (cups, grams, pieces, etc.)
     addedDate: DateTime
     notes: String (optional)
   }
   ```

2. **Add Items:**
   - Single item input (with autocomplete)
   - Bulk paste input (parse format: "ingredient quantity unit")
   - Barcode scanning (future feature)
   - Quantity and unit specification (optional)
   - Real-time validation against ingredient database

3. **Manage Items:**
   - View all pantry items in sortable/filterable list
   - Edit item quantity/unit
   - Delete items
   - Bulk delete (select multiple + delete)
   - Undo for recent deletions (within session)
   - Search by ingredient name

4. **Pantry Integration with Planning:**
   - Meal plan generation prioritizes recipes using pantry items
   - Grocery list removes pantry items from purchase list
   - Pantry items highlighted in meal plan (show in recipe view)
   - Clear visual indication of "already have" items

5. **Pantry Optimization (MVP Phase):**
   - Simple "priority" flag (mark items expiring soon)
   - Meal plan generation considers prioritized items
   - (Advanced: expiration dates and automatic prioritization - post-MVP)

---

#### 8.1.4 User Authentication & Authorization

**Requirement ID:** FR-004  
**Title:** Secure User Authentication

**Description:**
The system must securely authenticate users and manage sessions.

**Functional Specifications:**

1. **Authentication Methods:**
   - Email/password signup and login
   - Social login (Google OAuth, Apple Sign-In)
   - Password reset via email

2. **Account Management:**
   - User registration with email validation
   - Unique email constraint per user
   - User profile: name, email, preferences
   - User session with JWT tokens
   - Secure password hashing (bcrypt, salt ≥10 rounds)

3. **Session Management:**
   - JWT token validity: 7 days
   - Refresh token validity: 30 days
   - Auto-logout on token expiry
   - Force logout: all sessions invalidated on password change
   - Session persistence across app restart (auto-login if token valid)

4. **Security Requirements:**
   - HTTPS only
   - Password minimum: 8 characters
   - Rate limiting on login attempts (5 failed attempts = 15-min lockout)
   - Password reset link expires in 24 hours
   - Secure logout: clear tokens on device and backend

5. **Data Protection:**
   - User data encrypted at rest (database)
   - Sensitive data (passwords) never logged
   - PII compliant with GDPR

---

#### 8.1.5 User Preferences & Personalization

**Requirement ID:** FR-005  
**Title:** User Preference Management

**Description:**
The system must store and respect user preferences for meal planning.

**Functional Specifications:**

1. **Preference Data Model:**
   ```
   UserPreferences {
     userId: UUID
     servings: Integer (1, 2, 3+)
     dietaryPreferences: String[] (Vegetarian, Vegan, Keto, Paleo, etc.)
     cookingTimeAvailability: String (Low, Medium, High)
     weeklyBudget: Float (optional)
     allergies: String[] (Nuts, Dairy, Gluten, Shellfish, Soy, Eggs)
     mealsPerDay: Integer (2-4)
     mealTypes: String[] (Breakfast, Lunch, Dinner, Snacks)
     updatedAt: DateTime
   }
   ```

2. **Preference Updates:**
   - Editable from Settings screen
   - Changes take effect on next meal plan generation
   - Preferences persist across sessions
   - Changes logged (analytics)

3. **Constraint Enforcement:**
   - All dietary preferences honored in meal planning
   - All allergies strictly excluded from meal planning
   - Cooking time respected in recipe selection
   - Budget constraint applied to plan generation
   - Number of servings affects recipe scaling

---

#### 8.1.6 Notification System (Basic)

**Requirement ID:** FR-006  
**Title:** Push Notification Management

**Description:**
The system must send push notifications for key events (MVP: simple reminder, post-MVP: expanded).

**Functional Specifications:**

1. **Notification Types (MVP):**
   - Weekly plan reminder (e.g., "Plan your week for Sunday")
   - Tip/feature discovery (e.g., "Try Quick Meal mode")

2. **Notification Management:**
   - User toggles notifications on/off in Settings
   - Respect user timezone for scheduling
   - User preferences stored in backend and device

3. **Technical:**
   - Firebase Cloud Messaging (FCM) for Android
   - Apple Push Notification service (APNs) for iOS
   - Fallback if push registration fails (graceful)

---

### 8.2 Specific Technical Functional Requirements

#### 8.2.1 API Architecture

**Requirement ID:** FR-007  
**Title:** RESTful API Design

**Description:**
The backend must provide RESTful API endpoints for all client operations.

**Key API Endpoints (MVP):**

```
Authentication:
POST   /api/v1/auth/signup
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
POST   /api/v1/auth/password-reset

User Profile:
GET    /api/v1/user/profile
PUT    /api/v1/user/profile
GET    /api/v1/user/preferences
PUT    /api/v1/user/preferences

Meal Plans:
POST   /api/v1/meal-plans/generate
GET    /api/v1/meal-plans/{planId}
GET    /api/v1/meal-plans (list user's plans)
DELETE /api/v1/meal-plans/{planId}
PUT    /api/v1/meal-plans/{planId}/swap-meal

Grocery Lists:
GET    /api/v1/grocery-lists/{planId}
PUT    /api/v1/grocery-lists/{listId}/items/{itemId}

Pantry:
POST   /api/v1/pantry/items
GET    /api/v1/pantry/items
PUT    /api/v1/pantry/items/{itemId}
DELETE /api/v1/pantry/items/{itemId}

Recipes (Read-Only):
GET    /api/v1/recipes/{recipeId}
GET    /api/v1/recipes (search, paginated)

Settings:
PUT    /api/v1/settings/notifications
```

**API Standards:**
- JSON request/response bodies
- HTTP status codes correctly used
- Error responses with clear messages
- Pagination for list endpoints (limit, offset)
- Rate limiting: 1000 req/min per user
- Caching headers for static resources (recipes, etc.)

---

#### 8.2.2 Database Schema

**Requirement ID:** FR-008  
**Title:** Database Design

**Key Tables (PostgreSQL):**

```sql
-- Users
users {
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255),
  name VARCHAR(255),
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  last_login TIMESTAMP
}

-- User Preferences
user_preferences {
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  servings INT,
  dietary_preferences TEXT[],
  cooking_time_availability VARCHAR(50),
  weekly_budget DECIMAL(10,2),
  allergies TEXT[],
  created_at TIMESTAMP,
  updated_at TIMESTAMP
}

-- Recipes
recipes {
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  prep_time_minutes INT,
  cook_time_minutes INT,
  difficulty VARCHAR(50),
  servings INT,
  ingredients JSONB,
  instructions TEXT,
  dietary_tags TEXT[],
  allergen_flags TEXT[],
  estimated_cost DECIMAL(10,2),
  created_at TIMESTAMP
}

-- Ingredients
ingredients {
  id UUID PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  category VARCHAR(100),
  unit VARCHAR(50),
  base_cost DECIMAL(10,2),
  allergen_flags TEXT[]
}

-- Meal Plans
meal_plans {
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  start_date DATE,
  end_date DATE,
  total_estimated_cost DECIMAL(10,2),
  meals JSONB,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
}

-- Grocery Lists
grocery_lists {
  id UUID PRIMARY KEY,
  meal_plan_id UUID REFERENCES meal_plans(id),
  user_id UUID REFERENCES users(id),
  items JSONB,
  total_cost DECIMAL(10,2),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
}

-- Pantry Items
pantry_items {
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  ingredient_id UUID REFERENCES ingredients(id),
  quantity DECIMAL(10,2),
  unit VARCHAR(50),
  added_date TIMESTAMP,
  priority BOOLEAN DEFAULT FALSE
}

-- User Settings
user_settings {
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id) UNIQUE,
  notifications_enabled BOOLEAN DEFAULT TRUE,
  push_token VARCHAR(500),
  timezone VARCHAR(50),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
}

-- Analytics Events
analytics_events {
  id UUID PRIMARY KEY,
  user_id UUID,
  event_type VARCHAR(100),
  event_data JSONB,
  timestamp TIMESTAMP
}
```

---

## 9. Business Rules

### 9.1 Core Business Rules

#### BR-001: Onboarding Completion
- Onboarding must be completed in <60 seconds for >95% of users
- Users must provide: number of people, dietary preference, cooking time
- Budget and allergies are optional but recommended
- Onboarding skips unfinished if user manually starts using app

#### BR-002: Meal Plan Generation
- Meal plan generation must respect ALL hard constraints (allergies, dietary preferences)
- Budget constraint is respected but can be exceeded if no alternative exists (flagged to user)
- Plan must include variety (no recipe appears >1x/week)
- Meal plan generation must complete in <3 seconds
- Users on free tier limited to 2 plans/month; premium unlimited

#### BR-003: Grocery List Accuracy
- Grocery list must account for pantry items (no double-buying)
- Cost calculations use base ingredient pricing ± regional adjustments
- If cost data unavailable for an ingredient, flag as "price estimate unavailable"
- Pantry items are shown as "already have" but still visible for reference

#### BR-004: Pantry Management
- Pantry items persist until user deletes them
- Pantry items have no expiration tracking in MVP (simple model)
- User can mark item as "priority" to influence meal planning
- Pantry items are user-specific (not shared across accounts in MVP)

#### BR-005: Budget Enforcement
- If user sets weekly budget, meal plans aim to stay within 90-110% of budget
- If plan exceeds budget, "Cheaper" filter available to regenerate
- Total cost must be communicated clearly to user before purchase
- Premium users can see cost breakdown per meal

#### BR-006: Dietary & Allergy Constraints
- NO recipe with flagged allergen can appear in plan, ever
- Dietary preferences (Vegetarian, Vegan, etc.) are strict unless user modifies
- User cannot accidentally bypass allergy restrictions
- If no recipes match constraints, system shows error with suggestion to relax

#### BR-007: Authentication & Sessions
- Users must be logged in to use core features
- Sessions expire after 30 days of inactivity
- Logout clears all local session data
- Password reset emails expire in 24 hours
- Failed login attempts locked out for 15 minutes after 5 failures

#### BR-008: Data Retention & Privacy
- User data retained as long as account exists
- Deleted meal plans archived (not exposed to user) for 30 days, then hard-deleted
- User can request data export (future compliance feature)
- No personal data shared with 3rd parties (except authentication providers)

#### BR-009: Pricing & Monetization
- Free tier: 2 meal plans/month, basic grocery list, basic pantry
- Premium tier: $3.99–6.99/month (region-specific, TBD via validation)
- Free trial: 7 days of premium access post-signup (optional, promotional)
- Subscription cancellation effective immediately; no refunds for partial month

#### BR-010: Plan Swaps & Modifications
- User can swap individual meals up to 5 times per plan
- Grocery list updates automatically after each swap
- Undo available for last 3 swaps within a session
- Swapping a meal doesn't increase the plan's cost (same category/budget range)

---

### 9.2 Data Validation Rules

#### DVR-001: User Input Validation
- Email must be valid email format
- Password minimum 8 characters, must include 1 number and 1 uppercase letter
- Name must be 2-100 characters
- Budget must be positive number or null
- Quantities must be positive decimal numbers
- Cooking time must be one of: (Low, Medium, High)
- Number of people: 1, 2, or 3+

#### DVR-002: Recipe Data Validation
- Recipe name: 3-255 characters
- Prep time: 0-180 minutes
- Cook time: 0-240 minutes
- Servings: 1-12
- Cost: positive decimal, ≤$50
- Ingredients: at least 2, max 30
- Instructions: at least 10 characters

#### DVR-003: Ingredient Data Validation
- Ingredient name: 2-100 characters, unique
- Unit: one of predefined units (cups, grams, ml, pieces, tbsp, tsp, etc.)
- Cost: positive decimal or null
- Category: one of predefined categories

---

## 10. User Flows

### 10.1 Onboarding Flow (Happy Path)

```
App Start
  ↓
[Is User Logged In?]
  → YES → Go to Home Screen
  → NO ↓
[Login/Signup Screen]
  → Sign Up ↓
[Enter Email & Password] ↓
[Validate & Create Account] ↓
[Welcome Screen - Value Prop] (15 sec)
  ↓
[Quick Preferences Form] (30–45 sec)
  - Number of people
  - Dietary preferences
  - Cooking time availability
  - Optional: Budget, Allergies
  ↓
[Confirm Preferences] ↓
[Generate First Meal Plan] (backend processing, <3 sec)
  ↓
[Display Generated Plan] ↓
[Home Screen - First Plan Visible]
  → User can now:
    - View/adjust plan
    - View grocery list
    - Manage pantry
    - View settings
```

### 10.2 Meal Planning Flow (Recurring)

```
Home Screen
  ↓
[User taps "Plan This Week"]
  ↓
[App collects current preferences from profile]
  ↓
[Query pantry items]
  ↓
[Call Meal Plan Generation API]
  ↓
[Backend Algorithm:
  - Filter recipes by constraints
  - Respect budget
  - Prioritize pantry items
  - Ensure variety
  - Calculate costs
]
  ↓
[Return generated plan to mobile app]
  ↓
[Display 7-day meal plan with cards]
  ↓
[User Options:
  - Tap "View Grocery List" → See full list
  - Tap "Faster/Healthier/Cheaper" → Regenerate with filter
  - Tap meal → See details & swap options
  - Swipe → Mark as liked/disliked
  - Save plan → Auto-saved
]
```

### 10.3 Grocery Shopping Flow

```
Home Screen
  ↓
[User views meal plan or taps "View Grocery List"]
  ↓
[Grocery List screen opens]
  ↓
[List organized by category]
[Each item shows: Name | Qty | Unit | Est. Cost]
  ↓
[User Options:
  - Check off items as shopping
  - Add custom items (not in recipe)
  - Remove items
  - Modify quantities
  - Filter by "items to buy" (hide pantry items)
  - Search for specific items
]
  ↓
[Total cost calculated & displayed]
  ↓
[User taps "Export/Share"]
  ↓
[Options:
  - Copy to clipboard
  - Send via SMS/email/WhatsApp
  - Generate shareable link
  - Print (future)
]
```

### 10.4 Pantry Management Flow

```
Home Screen or Settings
  ↓
[User taps "Manage Pantry"]
  ↓
[Pantry screen opens, shows current items]
  ↓
[User taps "Add Items"]
  ↓
[Input Options:
  Option A: Single item
    - Type ingredient name
    - Autocomplete from DB
    - Enter quantity (optional)
    - Select unit (optional)
    - Confirm
  Option B: Bulk paste
    - Paste list in format: "egg 12\nmilk 1L\nflour 500g"
    - Parse & confirm items
    - Bulk save
]
  ↓
[Items added to pantry, appear in list]
  ↓
[User can:
  - Edit quantity/unit
  - Delete items
  - Mark as "priority" (will use soon)
  - Search items
]
  ↓
[Pantry items automatically factored into next meal plan]
```

### 10.5 Settings & Preferences Flow

```
Home Screen
  ↓
[User taps "Settings" icon]
  ↓
[Settings screen opens, shows sections:]
  - Profile (name, email)
  - Preferences (diet, budget, time, allergies)
  - Notifications (toggle on/off)
  - Account (logout, password reset)
  - App info (version, support)
  ↓
[User selects section to edit]
  ↓
[Edit form opens with current values]
  ↓
[User modifies and taps "Save"]
  ↓
[Changes persisted to backend]
  ↓
[Confirmation message]
  ↓
[Return to Settings]
```

### 10.6 Error Recovery Flow

```
[User action triggered]
  ↓
[API Request]
  ↓
[Is Response Successful?]
  → YES → Display result
  → NO ↓
[Error Type?]
  → Network Error ↓
      [Show "Check your connection" message]
      [Retry button]
  → API Error (4xx/5xx) ↓
      [Show user-friendly error message]
      [Suggestion: try again, contact support]
      [Log error details for debugging]
  → Validation Error ↓
      [Highlight invalid field]
      [Show specific error message]
  → Timeout ↓
      [Show "Request taking longer than expected"]
      [Retry button]
  ↓
[User can retry or go back]
```

---

## 11. Non-Functional Requirements

### 11.1 Performance Requirements

#### NFR-001: Response Time
- Onboarding completion: <60 seconds total (interactive)
- Meal plan generation API: <3 seconds
- Grocery list display: <2 seconds
- Pantry item search: <500ms
- Profile update: <2 seconds
- All API endpoints: <1 second (except meal plan generation)

#### NFR-002: Scalability
- Support 100+ concurrent users in beta phase
- Database queries optimized for 10,000+ user scale
- Horizontal scaling architecture (stateless backend)
- Load balanced API servers

#### NFR-003: Availability
- Target uptime: 99.5% (beta phase)
- Graceful degradation: if meal plan service down, show cached previous plan
- Database backup: daily automated backups

### 11.2 Security Requirements

#### NFR-004: Data Security
- All sensitive data encrypted at rest (AES-256)
- HTTPS/TLS 1.2+ for all communications
- JWT tokens signed with RS256 algorithm
- Password hashing: bcrypt with salt rounds ≥10
- No plaintext passwords logged
- PII handling compliant with GDPR

#### NFR-005: Authentication & Authorization
- JWT-based stateless authentication
- Role-based access control (basic: User, Admin)
- API rate limiting: 1,000 requests/user/hour
- Login attempt limiting: 5 failures = 15-min lockout
- Session timeout: 30 days of inactivity

#### NFR-006: Data Privacy
- User data isolated by user ID (no cross-user data leaks)
- API endpoints enforce user ownership checks
- Audit logging for sensitive operations (login, data access)
- Data retention policy: delete on account deletion

### 11.3 Reliability & Error Handling

#### NFR-007: Error Handling
- Graceful error messages (no technical jargon)
- Automatic error logging and reporting
- Retry logic for transient failures (3 attempts with exponential backoff)
- Fallback values where appropriate (e.g., use cached plan if generation fails)
- User-facing error codes for support troubleshooting

#### NFR-008: Data Consistency
- Transactional operations for critical flows (account creation, plan generation)
- Optimistic locking for concurrent updates
- Eventual consistency acceptable for non-critical data

### 11.4 Compatibility & Platform Requirements

#### NFR-009: Mobile Platform Support
- iOS: minimum version 14.0
- Android: minimum version 10 (API level 29)
- Screen sizes: 4.5–6.7 inches supported
- Landscape and portrait orientation support
- Offline support: basic (error shown if offline)

#### NFR-010: Browser & Backend Requirements
- Backend: Java 11+ (OpenJDK or Oracle JDK)
- PostgreSQL: 12+
- Node.js (if using Node for some services): 16+

### 11.5 Usability Requirements

#### NFR-011: User Experience
- Onboarding flow: clear, linear, no backtracking
- Onboarding completion: >95% of users complete in <60 seconds
- Gesture support: swipe, tap, long-press (standard iOS/Android patterns)
- Accessibility: WCAG 2.1 Level AA compliance
- Text readability: minimum font size 12pt, good contrast ratios

#### NFR-012: Localization (Future)
- MVP supports English and French
- Number/currency formatting by locale
- Date formatting by locale
- Translation strings in separate JSON files (i18n architecture in place)

### 11.6 Testing Requirements

#### NFR-013: Code Quality
- Unit test coverage: ≥80% of business logic
- Integration test coverage: ≥60% of API endpoints
- Performance tests for critical paths (meal plan generation, list retrieval)
- Load testing at 100+ concurrent users
- Security tests: OWASP Top 10, SQL injection, XSS, CSRF

---

## 12. Technical Considerations

### 12.1 Technology Stack

#### Frontend (Mobile)
- **Framework:** React Native (or Flutter as alternative)
- **Version:** React Native 0.72+
- **State Management:** Redux or Context API
- **HTTP Client:** Axios or React Native Fetch
- **Local Storage:** AsyncStorage (React Native)
- **Analytics:** Firebase Analytics + custom events
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Authentication:** Firebase Auth / Auth0 (JWT management)
- **UI Component Library:** React Native Paper or custom components

**Dependency Highlights:**
- `react-native-navigation` (navigation library)
- `axios` (HTTP client)
- `redux`, `react-redux` (state management)
- `redux-saga` (async middleware)
- `moment` or `date-fns` (date handling)

#### Backend
- **Language:** Java 11+
- **Framework:** Spring Boot 2.7+ (or 3.0+)
- **Build Tool:** Maven or Gradle
- **Database:** PostgreSQL 12+
- **ORM:** Hibernate / JPA
- **API Design:** Spring MVC (REST)
- **Authentication:** Spring Security + JWT (jjwt library)
- **Validation:** Hibernate Validator
- **Logging:** SLF4J + Logback
- **Testing:** JUnit 5, Mockito, Integration tests with TestContainers

**Key Dependencies:**
- `spring-boot-starter-web` (REST API)
- `spring-boot-starter-data-jpa` (database)
- `spring-boot-starter-security` (authentication)
- `springdoc-openapi-ui` (Swagger/OpenAPI documentation)
- `io.jsonwebtoken` (JWT handling)
- `postgresql` (driver)
- `junit-jupiter` (testing)

#### Database
- **Primary:** PostgreSQL 12+
- **Schema:** Entity-relationship diagram (ERD) provided separately
- **Connection Pooling:** HikariCP (Spring Boot default)
- **Migrations:** Flyway or Liquibase
- **Indexing:** B-tree indexes on frequently queried columns
- **Replication:** (future) master-slave replication for HA

#### Cloud Infrastructure
- **Provider:** Amazon Web Services (AWS)
- **Compute:** EC2 (t3.small for MVP) or ECS (containerized)
- **Database:** RDS PostgreSQL (managed)
- **Storage:** S3 (for recipe images, user uploads - future)
- **CDN:** CloudFront (for static assets)
- **Load Balancing:** Application Load Balancer (ALB)
- **Monitoring:** CloudWatch (logs, metrics)
- **Backup:** RDS automated backups

#### DevOps & Deployment
- **Containerization:** Docker (Dockerfile for backend)
- **Container Registry:** Amazon ECR
- **Orchestration:** ECS or Kubernetes (future)
- **CI/CD:** GitHub Actions or AWS CodePipeline
- **Infrastructure as Code:** Terraform (optional, AWS CloudFormation alternative)
- **Version Control:** Git (GitHub)
- **Environment:** Staging and Production environments

### 12.2 Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                  Mobile Apps                         │
│         React Native (iOS/Android)                   │
│  [Home] [Plan] [List] [Pantry] [Settings]           │
└──────────────────┬──────────────────────────────────┘
                   │ HTTPS/REST
                   ↓
┌─────────────────────────────────────────────────────┐
│           Load Balancer (AWS ALB)                    │
└──────────────────┬──────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        ↓                     ↓
┌──────────────────┐  ┌──────────────────┐
│  Spring Boot API │  │  Spring Boot API │
│   (Instance 1)   │  │   (Instance 2)   │
└────────┬─────────┘  └────────┬─────────┘
         │                     │
         └──────────┬──────────┘
                    ↓
         ┌──────────────────────┐
         │  PostgreSQL (RDS)    │
         │  - Users             │
         │  - Preferences       │
         │  - Meal Plans        │
         │  - Grocery Lists     │
         │  - Pantry Items      │
         │  - Recipes (static)  │
         │  - Ingredients (static) │
         └──────────────────────┘
         
         Other Services:
         - Firebase Auth (signup/login)
         - Firebase Messaging (push notifications)
         - AWS S3 (future: images)
         - SendGrid (email - password reset)
```

### 12.3 Data Flow & Integration Points

#### Meal Plan Generation Flow (Internal Process)
```
1. Mobile app: User taps "Plan This Week"
2. Mobile app: Sends POST /api/v1/meal-plans/generate
   {
     userId: <from JWT>,
     preferences: <from DB or request>
   }
3. Backend: Validates user JWT
4. Backend: Fetches user preferences from DB
5. Backend: Fetches pantry items from DB
6. Backend: Executes meal plan generation algorithm
   a. Filters recipe DB by constraints
   b. Applies budget logic
   c. Calculates costs
   d. Returns plan data structure
7. Backend: Saves meal plan to DB
8. Backend: Returns meal plan JSON to mobile
9. Mobile: Displays generated plan
10. Mobile: Stores plan locally (async cache)
11. User: Can view, adjust, generate grocery list
```

#### Grocery List Generation Flow
```
1. Mobile: User views meal plan, taps "Grocery List"
2. Mobile: Sends GET /api/v1/grocery-lists/{planId}
3. Backend: Validates ownership (planId belongs to user)
4. Backend: Fetches meal plan from DB
5. Backend: Extracts all recipe ingredients
6. Backend: Fetches user pantry from DB
7. Backend: De-duplicates & excludes pantry items
8. Backend: Fetches ingredient pricing data
9. Backend: Calculates total cost
10. Backend: Organizes by category
11. Backend: Returns grocery list JSON
12. Mobile: Displays organized list
13. User: Can check off, add, remove, export items
```

### 12.4 API Design Patterns

#### Standard Request/Response Format

**Request:**
```json
{
  "userId": "uuid-string",
  "data": {
    "field1": "value1",
    "field2": 123
  }
}
```

**Success Response (2xx):**
```json
{
  "success": true,
  "data": {
    "id": "uuid-string",
    "field1": "value1"
  },
  "message": "Operation completed successfully"
}
```

**Error Response (4xx/5xx):**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_INPUT",
    "message": "Budget must be a positive number",
    "details": [
      {
        "field": "weekly_budget",
        "issue": "Must be >= 0"
      }
    ]
  }
}
```

#### Pagination
```json
{
  "success": true,
  "data": [
    { "id": 1, "name": "Item 1" },
    { "id": 2, "name": "Item 2" }
  ],
  "pagination": {
    "limit": 10,
    "offset": 0,
    "total": 42
  }
}
```

### 12.5 Meal Plan Generation Algorithm (MVP)

**Pseudocode (High-Level):**

```
function generateMealPlan(userId, preferences):
  // 1. Fetch constraints
  constraints = {
    dietary: preferences.dietary_preferences,
    allergies: preferences.allergies,
    cookingTime: preferences.cooking_time_availability,
    budget: preferences.weekly_budget,
    servings: preferences.servings
  }
  
  // 2. Fetch available recipes
  recipes = database.query(
    WHERE dietary_compatibility IN constraints.dietary
    AND cooking_time <= maxTimePerMeal(constraints.cookingTime)
    AND NO allergies IN recipe.allergen_flags
  )
  
  // 3. Fetch user pantry
  pantryItems = database.getPantry(userId)
  
  // 4. Score recipes
  for each recipe in recipes:
    score = 0
    if recipe uses items in pantryItems:
      score += 50  // Prioritize pantry items
    if recipe cost <= budget/7:
      score += 30  // Budget-friendly recipes scored higher
    if recipe recently_used:
      score -= 20  // Deprioritize repetition
    recipe.score = score
  
  // 5. Select meals for 7 days
  mealPlan = []
  selectedRecipes = Set()
  
  for day = 1 to 7:
    for mealType in [Breakfast, Lunch, Dinner]:
      // Filter by score, avoid duplicates
      candidates = recipes.sortByScore()
        .filter(!selectedRecipes.contains)
        .limit(3)
      
      selected = candidates[0]  // Highest score
      mealPlan.add({
        day: day,
        mealType: mealType,
        recipe: selected
      })
      selectedRecipes.add(selected.id)
  
  // 6. Calculate total cost and aggregate ingredients
  groceryList = []
  totalCost = 0
  
  for each meal in mealPlan:
    for each ingredient in meal.recipe.ingredients:
      if ingredient NOT in pantryItems:
        groceryList.add(ingredient)
        totalCost += ingredient.cost
  
  // 7. Validate against budget
  if totalCost > constraints.budget * 1.1:
    // Cost exceeded; either flag or regenerate with cheaper recipes
    return mealPlan with warning
  
  return {
    meals: mealPlan,
    groceryList: groceryList,
    totalCost: totalCost
  }
```

**Optimization Notes:**
- Use database indexes on: dietary_tags, allergen_flags, cooking_time
- Cache recipe database in memory or Redis (rarely changes)
- Use pagination/limits to avoid processing all recipes
- Can be enhanced with machine learning (collaborative filtering) in v2.0

### 12.6 Security Considerations

#### JWT Token Management
- **Token Structure:** 
  ```
  Header: { alg: "HS256", typ: "JWT" }
  Payload: { 
    userId: "uuid", 
    email: "user@example.com",
    iat: timestamp,
    exp: timestamp + 7days
  }
  Signature: HMAC-SHA256(header.payload, secret_key)
  ```
- **Secret Key:** Stored securely in AWS Secrets Manager
- **Rotation:** Secret key rotated every 90 days

#### API Security
- **HTTPS Only:** Redirect all HTTP to HTTPS
- **CORS:** Restrict to mobile app domains
- **Rate Limiting:** 1,000 requests/user/hour, 50 requests/minute per IP
- **Input Validation:** All inputs validated and sanitized
- **SQL Injection Prevention:** Parameterized queries (Spring Data JPA)
- **XSS Prevention:** (Mobile-specific, less relevant) Output encoding

#### Sensitive Data Handling
- No passwords logged
- Sensitive responses not cached
- User data encrypted at rest (RDS encryption enabled)
- PII fields masked in logs
- GDPR compliance: data export/deletion endpoints

### 12.7 Monitoring & Observability

#### Logging
- **Framework:** SLF4J + Logback
- **Log Levels:** DEBUG (dev), INFO (prod)
- **Structure:** JSON logging for easy parsing
- **Retention:** 30 days in CloudWatch
- **Critical Events Logged:**
  - User signup/login
  - Meal plan generation (start, success, failure)
  - API errors
  - Database errors
  - Authentication failures

#### Metrics & Dashboards
- **CloudWatch Metrics:**
  - API response times (per endpoint)
  - Error rates (by endpoint, by error type)
  - Database connection pool utilization
  - Backend instance CPU/memory
- **Custom Metrics:**
  - Meal plan generation success rate
  - User activation rate
  - Feature usage (which features used most)
- **Dashboard:** Real-time metrics dashboard accessible to team

#### Alerts
- **High-Priority Alerts:**
  - API error rate >5%
  - Database connection pool exhaustion
  - Meal plan generation success rate <95%
  - API response time > 5 seconds (p95)
- **Medium-Priority Alerts:**
  - Database size growing rapidly
  - Backup failures
- **Notification Channels:** Email, Slack

---

## 13. Analytics Requirements

### 13.1 Event Tracking

#### Core Events (All Must Be Tracked)

| Event | Trigger | Data Captured |
|-------|---------|---------------|
| app_installed | App first opens | deviceType, osVersion, appVersion |
| app_launched | App opened | sessionId, timestamp, source |
| onboarding_started | User begins onboarding | userId, timestamp |
| onboarding_step_completed | User completes each step | step_number, time_spent_seconds |
| onboarding_completed | Full onboarding done | userId, totalTime_seconds |
| onboarding_abandoned | User quits onboarding | userId, step_abandoned_at, reason |
| signup_completed | Account created | email, signupMethod (email/google/apple) |
| login_completed | User logs in | userId, loginMethod |
| logout_completed | User logs out | userId, timestamp |
| preferences_updated | User changes preferences | changedFields, oldValues, newValues |
| meal_plan_generated | Plan created | planId, generationTime_ms, planCost, mealCount |
| meal_plan_viewed | User views generated plan | planId, viewDuration_seconds |
| meal_swapped | User swaps meal in plan | planId, mealId, swapCount |
| meal_plan_deleted | Plan removed | planId, ageOfPlan_days |
| grocery_list_viewed | User views grocery list | planId, viewDuration_seconds |
| grocery_list_checked | User checks off item | itemCount, checkRate |
| grocery_list_exported | List exported/shared | exportFormat (text/link/share), shareMethod |
| pantry_item_added | Item added to pantry | itemCount_total, bulkAdd_yn |
| pantry_item_removed | Item removed from pantry | itemCount_total |
| pantry_item_searched | User searches pantry | searchTerm, resultsFound |
| quick_meal_requested | User taps "Quick Meal" | mealReturnedCount |
| filter_applied | User applies Quick Filter | filterType (faster/healthier/cheaper) |
| settings_accessed | User opens Settings | settingsSectionAccessed |
| notification_received | Push notification sent | notificationType, displayedOrDismissed |
| notification_tapped | User taps notification | notificationType, actionTaken |
| error_occurred | App error/exception | errorType, errorMessage, stackTrace, affectedFeature |
| api_request_failed | API call failed | endpoint, httpStatus, errorType |
| session_ended | User closes app | sessionDuration_seconds, lastScreen |
| conversion_to_premium | User upgrades | userId, purchasePrice, paymentMethod |
| premium_subscription_renewed | Auto-renewal | userId, renewalPrice |
| premium_subscription_cancelled | User cancels | userId, daysSubscribed, cancellationReason |

### 13.2 Funnel Tracking

#### Activation Funnel
```
App Install (100%)
  ↓
App Launch (target: 70%)
  ↓
Onboarding Started (target: 65%)
  ↓
Onboarding Completed (target: 60%)
  ↓
Account Created (target: 58%)
  ↓
Preferences Set (target: 56%)
  ↓
First Meal Plan Generated (target: 50%) [ACTIVATION]
  ↓
Grocery List Viewed (target: 45%)
  ↓
Pantry Item Added (target: 30%)
```

#### Monetization Funnel
```
Activated Users (100%)
  ↓
Viewed Premium Features (target: 30%)
  ↓
Started Premium Trial (target: 15%) [if offered]
  ↓
Converted to Premium (target: 5–10%)
  ↓
Renewed at Day-30 (target: 70% of converters)
```

### 13.3 Cohort Analysis

Track cohorts by:
- **Signup Date:** Weekly/monthly cohorts to track retention over time
- **Onboarding Completion Time:** Did users complete in <60s vs. longer?
- **Persona Segment:** By detected persona (busy pro, parent, student, health-conscious)
- **Geographic:** By country/region (if available)
- **Device:** iOS vs. Android retention differences
- **Premium Status:** Free vs. Premium user behavior

### 13.4 Retention Metrics (Critical)

| Metric | Definition | Target | Measurement |
|--------|-----------|--------|-------------|
| D1 Retention | % of Day-0 installs that generate ≥1 plan on Day-1 | ≥40% | Daily |
| D7 Retention | % of Day-0 installs that launch app on Day-7 | ≥25% | Weekly |
| D30 Retention | % of Day-0 installs that have generated ≥1 plan by Day-30 | ≥15% | Monthly |
| Weekly Return | % of active users returning in following week | ≥40% | Weekly |
| Monthly Churn | % of active users who don't return within 30 days | ≤20% | Monthly |
| Plan Repeat Rate | % of users generating 2+ plans | ≥50% | Monthly |

### 13.5 Engagement Metrics

| Metric | Definition | Target |
|--------|-----------|--------|
| Session Frequency | Avg sessions/user/week | ≥2.0 |
| Session Duration | Avg time/session | 3–8 min |
| Daily Active Users (DAU) | Unique users opening app/day | Track |
| Weekly Active Users (WAU) | Unique users generating plan/week | ≥100 (beta) |
| Feature Breadth | % of users using ≥3 features | ≥60% |
| Pantry Adoption | % of users adding ≥1 pantry item | ≥40% |
| List Share Rate | % of users exporting/sharing grocery list | ≥60% |

### 13.6 Analytics Dashboard (KPIs)

**Real-Time Dashboard (Updated hourly):**
- Installs (last 24h, cumulative)
- Signups (last 24h, cumulative)
- Active users (DAU, WAU, MAU)
- Onboarding completion rate
- Meal plans generated (last 24h)
- Session count & avg duration
- Error rate
- Top errors (by frequency)

**Weekly Report:**
- Activation funnel progress
- Retention cohorts (D1, D7, D30)
- Feature usage breakdown
- User segmentation (by persona)
- Premium conversion rate
- Top-performing content (recipes, features)

**Monthly Report:**
- Churn analysis
- User lifetime value (estimated)
- CAC (Customer Acquisition Cost) by channel
- LTV:CAC ratio
- Recommendations for optimization

### 13.7 Privacy & Compliance

- All events anonymized (no PII logged directly)
- GDPR-compliant: users can opt-out of non-essential analytics
- Data retention: 90 days in real-time analytics, 1 year in data warehouse
- No third-party ad tracking tools
- Privacy policy clearly discloses event tracking

---

## 14. Out of Scope

### 14.1 Features Explicitly NOT in MVP

- ⛔ **Family/Couple Account Sharing:** Complex authorization logic; post-MVP feature
- ⛔ **Barcode Scanning:** Hardware integration; post-MVP
- ⛔ **Expiration Date Tracking:** Requires additional pantry data model; post-MVP
- ⛔ **Macro/Calorie Tracking:** Detailed nutrition features; post-MVP
- ⛔ **Recipe Ratings & Favorites:** Social features; post-MVP
- ⛔ **E-Commerce Integration:** Shopping from app; post-MVP
- ⛔ **Voice Assistant:** Voice commands; post-MVP
- ⛔ **Web App:** Desktop version; post-MVP (mobile-first)
- ⛔ **Offline Mode:** Requires offline-first architecture; post-MVP
- ⛔ **Advanced Pantry Scanning:** OCR/AI-based receipt scanning; post-MVP
- ⛔ **Social Features:** Community, sharing plans, followers; post-MVP
- ⛔ **Meal Prep Coaching:** AI coaching features; post-MVP
- ⛔ **Smart Fridge Integration:** IoT connectivity; far future
- ⛔ **Restaurant Recommendations:** Different problem domain; out of scope
- ⛔ **Subscription Management:** Premium billing via Stripe/RevenueCat; integrated later
- ⛔ **Multi-Language Support:** English only for MVP (French possible if resources)

### 14.2 Platforms Not Supported

- ⛔ **Web App:** Mobile-first MVP; web version comes later
- ⛔ **Wearables:** Smartwatch integration; post-MVP
- ⛔ **Smart Home Devices:** Alexa, Google Home integration; post-MVP
- ⛔ **Desktop (Windows/macOS):** Not planned for MVP; web later

### 14.3 Integrations Not Included

- ⛔ **Third-Party Grocery Services:** Instacart, Amazon Fresh, local shops; post-MVP
- ⛔ **Calendar Sync:** Google Calendar, Apple Calendar integration; post-MVP
- ⛔ **Health Apps:** Apple Health, Google Fit integration; post-MVP
- ⛔ **Social Media Sharing:** Instagram, Pinterest integration; post-MVP
- ⛔ **Fitness Apps:** MyFitnessPal, Strava; post-MVP

### 14.4 Content Not Included

- No special diet plans (keto meal plans, Whole30, AIP) in recipe database; generic recipes only
- No restaurant/takeout integration; home cooking only
- No dietary supplements or vitamins tracking
- No meal prep strategies or tutorials (though recipe instructions included)

### 14.5 Monetization Features Not in MVP

- ⛔ **In-App Ads:** No advertising in MVP
- ⛔ **Sponsored Content:** No sponsored recipes or brands
- ⛔ **Affiliate Links:** No product links or commission-based content
- ⛔ **Loyalty Programs:** No rewards/points system

### 14.6 Support & Community (Not MVP)

- ⛔ **Live Chat Support:** Email/help center only; live support post-MVP
- ⛔ **In-App Help Tutorial:** Simple help section; no interactive tutorial
- ⛔ **User Community Forum:** Post-MVP
- ⛔ **User-Generated Content:** Ratings, reviews, custom recipes; post-MVP

---

## 15. Release Plan

### 15.1 MVP Timeline

| Phase | Duration | Key Activities | Output |
|-------|----------|----------------|--------|
| **Phase 0: Validation** | Weeks 1–2 | Survey (100+ responses), User interviews (10–15), Competitive analysis | Validated problem & market signals |
| **Phase 1: Design** | Weeks 3–4 | Wireframes, Design system, User flows, Technical architecture doc | Design deliverables, Approved PRD (this doc) |
| **Phase 2: Development Sprint 1** | Weeks 5–6 | Authentication, Onboarding, Home/Plan screen, API setup | Functional onboarding to first plan |
| **Phase 3: Development Sprint 2** | Weeks 7–8 | Grocery List, Pantry, Settings, Notification system | Complete core features |
| **Phase 4: Integration & Testing** | Week 9 | E2E testing, Performance testing, Security testing, Bug fixes | Bug-free MVP build |
| **Phase 5: Closed Beta** | Weeks 10–11 | Beta testing with 50–100 users, Feedback collection, Final polish | User feedback, Performance data |
| **Phase 6: Public Launch** | Week 12+ | App Store/Google Play submission, Marketing launch, Initial support | Live in app stores |

### 15.2 Sprint Breakdown (Agile)

**Sprint Duration:** 2 weeks  
**Sprint Planning:** Monday, Planning meeting 1h  
**Daily Standup:** 15min  
**Sprint Review:** Friday, Demo to stakeholders  
**Sprint Retrospective:** Friday, Continuous improvement  

#### Sprint 1 (Weeks 5–6): Authentication & Onboarding
- **Stories:** US-001, US-002, US-003
- **Dev Tasks:**
  - API: User signup/login endpoints
  - Mobile: Auth flow UI
  - Mobile: Onboarding screens
  - Database: User schema
  - JWT integration
- **Testing:** Unit tests for auth, E2E for onboarding flow
- **Acceptance:** Onboarding completes in <60 seconds, user can generate first plan

#### Sprint 2 (Weeks 7–8): Core Features
- **Stories:** US-005, US-008, US-009, US-010
- **Dev Tasks:**
  - API: Meal plan generation algorithm
  - API: Grocery list endpoints
  - API: Pantry CRUD endpoints
  - Mobile: Home/Plan screen UI
  - Mobile: Grocery List UI
  - Mobile: Pantry UI
  - Recipe database seeding (150–200 recipes)
- **Testing:** Algorithm tests, API tests, UI tests
- **Acceptance:** Users can generate plans, view lists, manage pantry

#### Sprint 3 (Weeks 9–10): Polish & Beta Prep
- **Stories:** US-011, US-012, US-013, misc. improvements
- **Dev Tasks:**
  - Error handling & edge cases
  - Performance optimization
  - Analytics integration
  - Beta testing infrastructure
  - Documentation
- **Testing:** Load testing, Stress testing, Beta user recruitment
- **Acceptance:** Build ready for closed beta, all critical paths functional

### 15.3 Go/No-Go Criteria for Each Phase

**Go-to-Design Gate (End of Phase 0):**
- ✅ 100+ survey responses received
- ✅ Average pain score ≥7/10
- ✅ ≥50% of respondents indicate weekly pain
- ✅ ≥30% express willingness to pay
- ✅ Competitive analysis complete

**Go-to-Development Gate (End of Phase 1):**
- ✅ Wireframes approved by product & design leads
- ✅ Technical architecture reviewed by lead engineer
- ✅ PRD finalized and approved
- ✅ Design system created (colors, typography, components)
- ✅ Development environment ready (repos, CI/CD)

**Go-to-Beta Gate (End of Phase 4):**
- ✅ All P0 user stories completed
- ✅ No P0 bugs open
- ✅ Activation funnel >50%
- ✅ Onboarding <60 seconds for >90% of test users
- ✅ Meal plan generation success rate >95%
- ✅ App Store builds ready (build artifacts created)

**Go-to-Launch Gate (End of Phase 5):**
- ✅ D1 Retention ≥40%
- ✅ D7 Retention ≥25%
- ✅ NPS ≥40 (from beta feedback)
- ✅ App Store/Google Play submissions approved
- ✅ Marketing assets prepared
- ✅ Support infrastructure ready (help email, basic FAQ)

### 15.4 Release Schedule

- **Closed Beta:** Weeks 10–11 (50–100 users, selected via waitlist)
- **Public Beta:** Week 12 (if viable; wider audience)
- **Public Launch (App Stores):** Week 13+
- **Post-Launch Monitoring:** Weeks 14–16 (daily metrics review, rapid bug fixes)

---

## 16. Open Questions

### 16.1 Product & Market

**Q1: Pricing Validation**
- What is the optimal price point for Premium? ($2.99, $3.99, $6.99, $9.99/month?)
- Should there be a free trial? (7-day, 14-day, 30-day?)
- Should pricing vary by region?
- Action: Conduct pricing survey during Phase 0; test in beta

**Q2: Recipe Database**
- How many recipes are enough for MVP? (150, 200, 500?)
- Should we include cuisine preferences (Italian, Asian, Mexican)?
- How often should recipes be updated/refreshed?
- Action: Analyze user survey feedback on recipe preferences; define minimum set

**Q3: Meal Frequency**
- Should users be able to set 2 meals/day vs. 3 meals/day?
- Should breakfast, lunch, dinner, snacks be independently configurable?
- Action: Determine from user personas; implement in onboarding

**Q4: Budget Handling**
- Should budget be per-meal, per-day, per-week, or per-month?
- What if user sets a budget that's impossible to achieve? (Error vs. warning?)
- Action: Clarify during Phase 1 design; test with users

**Q5: Pantry Scope**
- Should pantry have "expiration date" tracking in MVP? (Post-MVP if complexity)
- Should pantry be shared across meal plans, or per-plan?
- Should we auto-suggest "use this item soon" based on freshness?
- Action: Decide based on complexity vs. value trade-off

### 16.2 Technical

**Q6: Meal Plan Algorithm**
- Should algorithm be deterministic (same inputs = same plan) or randomized (variety)?
- How much should we weight pantry usage vs. other factors?
- Should user be able to adjust algorithm weights (advanced settings)?
- Action: Implement MVP with simple weighted scoring; gather feedback

**Q7: Database Scaling**
- At what user count should we consider read replicas or caching?
- Should recipe database be denormalized (cached in Redis)?
- Action: Plan for scale at 10k users; implement on-demand

**Q8: Image/Recipe Assets**
- Should we include recipe photos in MVP? (Adds complexity & storage)
- Who creates/owns recipe photos?
- Action: Decide based on UX research; may defer to Phase 1.1

**Q9: Backend Load Testing**
- At what concurrency level should the MVP backend be tested? (100, 500, 1000 users?)
- What's acceptable latency for meal plan generation? (<3s established, but flexible?)
- Action: Load test at 100 concurrent users; scale infrastructure as needed

**Q10: API Versioning**
- Should we version the API (/v1, /v2)? When?
- How do we handle backwards compatibility?
- Action: Implement v1 now; versioning strategy for Phase 1.1+

### 16.3 Monetization & Growth

**Q11: Premium Features**
- Which features should be Premium-only? (Unlimited plans, pantry, shared accounts, macros?)
- Should free tier be time-limited or feature-limited?
- Action: Define in Phase 0 survey; test in beta

**Q12: User Acquisition**
- What's the target CAC (Customer Acquisition Cost)?
- Should we use paid acquisition (ads) or organic only in MVP?
- Which channels are most effective? (Organic, referral, social, paid search?)
- Action: Plan detailed GTM strategy post-validation

**Q13: Retention Levers**
- What drives repeat usage? (Notifications, streaks, social pressure?)
- Should we implement a "streak" system or gamification?
- Action: Analyze beta user behavior; iterate on retention mechanics

**Q14: Growth Targets**
- What's the target DAU/MAU by month 3, 6, 12?
- What's a "successful" MVP launch? (1k users? 10k?)
- Action: Define KPI targets based on beta metrics

### 16.4 Operations & Support

**Q15: Customer Support**
- How do we support users in MVP? (Email, help center, in-app help?)
- What SLA do we commit to for support responses?
- Who handles support (founder, contractor, support team)?
- Action: Plan support infrastructure before launch

**Q16: Data Retention & Privacy**
- Should we implement GDPR right-to-deletion? (Yes, per legal requirements)
- How long do we retain user data after account deletion?
- Do we need DPA (Data Processing Agreement) with AWS?
- Action: Consult with legal; implement privacy infrastructure

**Q17: Localization**
- Should MVP support multiple languages or English-only?
- Which regions should we target first? (US, UK, EU?)
- Should pricing/currency be region-specific?
- Action: Decide based on initial user base; plan for expansion

### 16.5 Timeline & Resources

**Q18: Engineering Capacity**
- How many engineers needed for MVP? (1, 2, 3 full-stack devs?)
- Should we hire contractors for specific features?
- What's the total development cost?
- Action: Create hiring plan; budget accordingly

**Q19: Design Capacity**
- Dedicated designer or outsourced design?
- What's the design handoff process?
- Who implements design (designers or engineers)?
- Action: Define design process; allocate resources

**Q20: Timeline Confidence**
- Is the 12-week timeline realistic? (Buffer needed?)
- What are the biggest unknowns that could delay launch?
- Should we prioritize features or timeline?
- Action: Risk assessment; create contingency plan

---

## 17. Appendices

### 17.1 Glossary of Terms

| Term | Definition |
|------|-----------|
| MVP | Minimum Viable Product; smallest set of features to validate problem/solution |
| DAU | Daily Active Users |
| MAU | Monthly Active Users |
| WAU | Weekly Active Users |
| Activation | User completes onboarding and generates first meal plan |
| Retention | User returns to app within defined period (D1, D7, D30) |
| Churn | User stops using app and doesn't return |
| Premium | Paid subscription tier with additional features |
| Freemium | Free tier + paid premium tier model |
| Onboarding | Initial setup flow when user first launches app |
| Pantry | User's inventory of ingredients at home |
| Meal Plan | 7-day schedule of meals generated by algorithm |
| Grocery List | Shopping list generated from meal plan |
| Recipe | Single dish with ingredients, instructions, metadata |
| Ingredient | Individual food item (e.g., "salt," "chicken breast") |
| Dietary Preference | User's eating style (vegetarian, vegan, etc.) |
| Allergy | Ingredient user cannot eat (due to allergy/intolerance) |
| JWT | JSON Web Token; secure authentication mechanism |
| API | Application Programming Interface; backend communication |
| CTA | Call-To-Action; interactive button/prompt |
| UX | User Experience; how user interacts with product |
| Funnel | Sequence of steps users take (e.g., signup → activation) |
| Analytics | Data about user behavior and product metrics |
| KPI | Key Performance Indicator; critical business metric |
| NPS | Net Promoter Score; customer satisfaction metric |
| CSAT | Customer Satisfaction score |
| CAC | Customer Acquisition Cost |
| LTV | Lifetime Value; total revenue per user |
| ARPU | Average Revenue Per User |
| MRR | Monthly Recurring Revenue |
| Persona | Archetypal user profile representing a segment |
| User Story | Feature request written from user's perspective |
| Acceptance Criteria | Testable conditions for feature completion |
| Sprint | Time-boxed development cycle (typically 2 weeks) |
| Backlog | Collection of features/bugs prioritized for development |
| Wireframe | Low-fidelity UI mockup; information architecture |
| Prototype | Interactive mockup showing user flows |
| A/B Test | Experiment comparing two variants of a feature |

### 17.2 References & Resources

#### Competitive Analysis Documents
- Mealime feature breakdown
- AnyList vs. alternatives comparison
- Paprika Recipe Manager review
- User survey on existing solutions

#### Design Documents
- Wireframes (Figma link: [TBD])
- Design system (colors, typography, components)
- User flow diagrams
- Mobile app mockups

#### Technical Documents
- Database ERD (Entity-Relationship Diagram)
- API specification (OpenAPI/Swagger)
- Architecture diagram
- Deployment architecture

#### Research Documents
- User survey results (Google Forms export)
- User interview transcripts (10–15 interviews)
- Market research (market size, growth trends)
- Competitive feature matrix

#### Legal & Compliance
- Terms of Service (TBD)
- Privacy Policy (TBD)
- GDPR Compliance checklist
- Data Processing Agreement (AWS DPA)

### 17.3 Appendix: User Personas (Detailed)

[See Section 3.1 and Section 3.2 for full persona details]

### 17.4 Appendix: Meal Plan Algorithm Details

[See Section 12.5 for pseudocode and optimization notes]

### 17.5 Appendix: API Endpoint Details

[See Section 8.2.1 for full API endpoint list]

### 17.6 Appendix: Database Schema Details

[See Section 8.2.2 for full SQL schema]

### 17.7 Appendix: Analytics Events List

[See Section 13.1 for complete event catalog]

### 17.8 Document Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | May 12, 2026 | Product Team | Initial PRD created |
| 1.1 (TBD) | TBD | TBD | Post-validation updates |

### 17.9 Sign-Off

| Role | Name | Date | Sign-Off |
|------|------|------|----------|
| Product Manager | [Name] | [Date] | ☐ Approved |
| Engineering Lead | [Name] | [Date] | ☐ Approved |
| Design Lead | [Name] | [Date] | ☐ Approved |
| Founder/CEO | Prince Zeufack Tameze | [Date] | ☐ Approved |

---

## Document Metadata

**Document Title:** PlatePilot MVP Product Requirements Document (PRD) v1.0  
**Document Type:** Product Specification  
**Audience:** Product Team, Engineering Team, Design Team, Stakeholders  
**Status:** Draft (Ready for Validation Gate)  
**Last Updated:** May 12, 2026  
**Next Review Date:** After Phase 0 validation (Weeks 1–2)  
**Document Owner:** Product Manager / Founder  
**Accessibility:** Shared with development team via [repository/drive link]

---

## Final Notes for Development Team

### How to Use This Document

1. **Read the entire document** (Executive Summary through Appendices)
2. **Focus on sections 6 (MVP Scope) and 7 (User Stories)** as your primary work list
3. **Reference Section 8 (Functional Requirements)** for technical specifications
4. **Use Section 12 (Technical Considerations)** for architecture decisions
5. **Track progress against Section 15 (Release Plan)** sprints

### Key Success Factors

- **Simplicity First:** Every feature must justify its complexity
- **User-Centric:** Test decisions with actual users (beta testers)
- **Speed:** <60 second onboarding is non-negotiable
- **Quality:** >95% success rate for core features (meal plan generation, lists)
- **Data-Driven:** Every release backed by metrics and user feedback

### Getting Started

1. **Week 1:** Read this entire PRD; clarify any questions
2. **Week 1–2:** Complete Phase 0 validation (surveys, interviews)
3. **Week 3:** Design kickoff; wireframe creation begins
4. **Week 4:** Engineering setup (repos, CI/CD, environment)
5. **Week 5:** Development sprint 1 begins

---

**END OF DOCUMENT**

---

**This PRD is a living document. Updates will be made based on:**
- Phase 0 validation results
- Design iterations
- Development discoveries
- User feedback from beta testing

**Questions or clarifications? Please reach out to the Product Manager or Founder.**

