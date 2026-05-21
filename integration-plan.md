# PlatePilot — Frontend-Backend Integration Plan

## Architecture Pattern

```
Screen (Widget) → Provider (Riverpod StateNotifier) → Repository → ApiClient (Dio) → Backend
                                               ↕
                                        LocalStorage (fallback)
```

Each domain gets its own repository file. Repositories call `ApiClient`, parse JSON responses, return domain models. Providers manage loading/error/success states and fall back to local storage when backend is unreachable.

---

## Phase 1 — Auth Foundation (critical path)

### 1.1 Create `FlutterSecureStorage` wrapper

Auth tokens must never touch `SharedPreferences`. Use `flutter_secure_storage` for the access token + refresh token pair.

**File:** `lib/core/services/secure_storage_service.dart`

```dart
class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async { ... }
  Future<String?> getAccessToken() async { ... }
  Future<String?> getRefreshToken() async { ... }
  Future<void> clearTokens() async { ... }
}
```

### 1.2 Create `AuthRepository`

**File:** `lib/core/repositories/auth_repository.dart`

Maps to backend `AuthController` at `/api/v1/auth`:

| Method | Backend Endpoint | Purpose |
|--------|-----------------|---------|
| `login(email, password)` | `POST /auth/login` | Returns `{accessToken, refreshToken, tokenType, expiresIn}` |
| `register(name, email, password)` | `POST /auth/register` | Returns `{id, name, email, ...}` |
| `refreshToken(refreshToken)` | `POST /auth/refresh` | Returns new `{accessToken, refreshToken}` |
| `verifyEmail(token)` | `POST /auth/verify-email` | Confirms email |
| `forgotPassword(email)` | `POST /auth/forgot-password` | Sends reset email |
| `resetPassword(token, newPassword)` | `POST /auth/reset-password` | Resets password |
| `getMe()` | `GET /auth/me` | Returns current `UserResponse` |
| `logout()` | `POST /auth/logout` | Invalidates refresh token |

### 1.3 Update `ApiClient` auth interceptor

**File:** `lib/core/network/api_client.dart`

Replace stub `_AuthTokenInterceptor` with real logic:

1. On every request, read access token from `SecureStorageService`.
2. Attach `Authorization: Bearer <token>` header.
3. On `401` response, attempt refresh via `POST /auth/refresh`.
4. If refresh succeeds → retry original request with new token.
5. If refresh fails → clear tokens, redirect to login.

### 1.4 Create `AuthNotifier` provider

**File:** `lib/features/auth/providers/auth_provider.dart`

States: `unauthenticated`, `authenticated(User)`, `loading`, `error(String)`.

Actions: `login()`, `register()`, `logout()`, `checkSession()` (reads stored token, calls `/auth/me`).

### 1.5 Wire login/signup screens

Update `login_screen.dart` and `signup_screen.dart` to:
- Call `AuthNotifier.login/register`
- Show loading spinner during request
- Show error message on failure
- Navigate to home on success (GoRouter redirect)

---

## Phase 2 — Core Infrastructure

### 2.1 Create base response types

**File:** `lib/core/network/api_response.dart`

```dart
class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;
}

class PageResponse<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final bool first;
  final bool last;
}
```

### 2.2 Map backend DTOs to Dart models

Backend uses `snake_case` JSON. Add `JsonKey(name: ...)` mappings.

Key DTOs needed (15+ files in `lib/shared/models/`):
- `UserResponse` → `User` (id, name, email, avatarUrl, createdAt)
- `RecipeResponse` → `Recipe` (id, title, imageUrl, prepTime, cookTime, ingredients, steps, nutrition)
- `MealPlanResponse` → `MealPlan` (id, weekStart, entries: [{day, mealType, recipe}])
- `GroceryListResponse` → `GroceryList` (id, name, items: [{name, quantity, checked}])
- `PantryItemResponse` → `PantryItem` (id, name, quantity, expirationDate)
- `BudgetResponse` → `Budget` (id, monthlyLimit, spent)
- `NotificationResponse` → `AppNotification`
- `PreferenceResponse` → `UserPreferences` (dietary, allergies, cuisines)

**Regex helper:** Use `@JsonKey(name: 'snake_case_field')` on every field.

### 2.3 Create base repository class

**File:** `lib/core/repositories/base_repository.dart`

```dart
class BaseRepository {
  final ApiClient apiClient;
  BaseRepository(this.apiClient);

  T handleResponse<T>(Response response, T Function(Map<String, dynamic>) fromJson) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return fromJson(response.data as Map<String, dynamic>);
    }
    throw ApiException(response.data['message'] ?? 'Unknown error');
  }

  List<T> handleListResponse<T>(Response response, T Function(Map<String, dynamic>) fromJson) { ... }
  PageResponse<T> handlePageResponse<T>(Response response, T Function(Map<String, dynamic>) fromJson) { ... }
}
```

---

## Phase 3 — Preferences Integration

### 3.1 Replace `EditablePreferences` local-only provider

**Current:** `preferences_provider.dart` persists to `SharedPreferences` as JSON.
**Target:** Keep local as cache, but sync with backend `PreferenceController` at `/api/v1/preferences`.

### 3.2 Create `PreferenceRepository`

| Method | Backend Endpoint |
|--------|-----------------|
| `getPreferences()` | `GET /preferences/me` |
| `updatePreferences(dietaryTypes, allergies, cuisines, goals)` | `PUT /preferences/me` |

### 3.3 Preference ↔ DTO mapping

Backend model:
```json
{
  "dietaryTypes": ["VEGETARIAN", "VEGAN"],
  "allergies": ["GLUTEN", "DAIRY"],
  "cuisines": ["ITALIAN", "MEXICAN"],
  "goals": ["WEIGHT_LOSS", "HIGH_PROTEIN"],
  "mealPrepDay": "SUNDAY",
  "servingsPerMeal": 4
}
```

Frontend `EditablePreferences` has matching fields. Add `toJson()` / `fromJson()`.

### 3.4 Update onboarding flow

Onboarding final step currently reads preferences and stores locally. Change to:
1. If authenticated → call `POST /register` then `PUT /preferences/me`.
2. If not authenticated → save to local, sync after login.

---

## Phase 4 — Profile Integration

### 4.1 Create `ProfileRepository`

| Method | Backend Endpoint |
|--------|-----------------|
| `getProfile()` | `GET /profile` |
| `updateProfile(name, avatarUrl, ...)` | `PUT /profile` |
| `changePassword(oldPassword, newPassword)` | `PUT /profile/password` |
| `uploadAvatar(file)` | `POST /profile/avatar` (multipart) |
| `deleteAvatar()` | `DELETE /profile/avatar` |

### 4.2 Update `ProfileNotifier`

Keep `SharedPreferences` as cache, mark `isDirty` when data diverges from backend. On app start, `AuthNotifier.authenticated` triggers `ProfileNotifier.sync()`.

### 4.3 Wire ProfileScreen

All editable fields in `ProfileScreen` should:
- Load from `ProfileNotifier` on init.
- Save via `updateProfile()` on field change (debounced).
- Show success/error snackbar.

---

## Phase 5 — Recipe Integration

### 5.1 Create `RecipeRepository`

| Method | Backend Endpoint |
|--------|-----------------|
| `getRecipes(page, size, sort)` | `GET /recipes` |
| `getRecipeById(id)` | `GET /recipes/{id}` |
| `getPublicRecipes(page, size)` | `GET /recipes/public` |
| `createRecipe(recipe)` | `POST /recipes` |
| `updateRecipe(id, recipe)` | `PUT /recipes/{id}` |
| `deleteRecipe(id)` | `DELETE /recipes/{id}` |
| `rateRecipe(id, rating)` | `POST /recipes/{id}/rate` |
| `toggleFavorite(id)` | `POST /recipes/{id}/favorite` |
| `getFavorites(page, size)` | `GET /recipes/favorites` |
| `searchRecipes(query, filters)` | `GET /recipes/search` |

### 5.2 Wiring plan

- `HomeScreen` recipe recommendations → `getPublicRecipes()` or `getRecipes()`.
- `RecipeDetailScreen` → `getRecipeById(id)`, `rateRecipe()`, `toggleFavorite()`.
- `CustomRecipesScreen` → `createRecipe()`, `updateRecipe()`, `deleteRecipe()`.
- `FavoritesScreen` → `getFavorites()`.

---

## Phase 6 — Meal Plan Integration

### 6.1 Create `MealPlanRepository`

| Method | Backend Endpoint |
|--------|-----------------|
| `getWeeklyMealPlan()` | `GET /meal-plans/weekly` |
| `getCurrentMealPlan()` | `GET /meal-plans/current` |
| `createMealPlan(startDate, entries)` | `POST /meal-plans` |
| `updateMealPlan(id, entries)` | `PUT /meal-plans/{id}` |
| `deleteMealPlan(id)` | `DELETE /meal-plans/{id}` |
| `addEntry(mealPlanId, entry)` | `POST /meal-plans/{id}/entries` |
| `updateEntry(entryId, entry)` | `PUT /meal-plans/entries/{entryId}` |
| `deleteEntry(entryId)` | `DELETE /meal-plans/entries/{entryId}` |

### 6.2 Wire `PlanScreen`

- Currently shows `demo_data.dart` meal plan → `getWeeklyMealPlan()`.
- Day selector + meal grid → entries from meal plan response.
- Add meal → `addEntry()`, recipe picker.
- Edit → `updateEntry()`, swipe to delete → `deleteEntry()`.

---

## Phase 7 — Grocery Integration

### 7.1 Create `GroceryRepository`

| Method | Backend Endpoint |
|--------|-----------------|
| `getGroceryLists()` | `GET /grocery-lists` |
| `createGroceryList(name)` | `POST /grocery-lists` |
| `getGroceryList(id)` | `GET /grocery-lists/{id}` |
| `updateGroceryList(id, name)` | `PUT /grocery-lists/{id}` |
| `deleteGroceryList(id)` | `DELETE /grocery-lists/{id}` |
| `addItem(listId, item)` | `POST /grocery-lists/{id}/items` |
| `updateItem(itemId, item)` | `PUT /grocery-lists/items/{itemId}` |
| `deleteItem(itemId)` | `DELETE /grocery-lists/items/{itemId}` |
| `toggleItem(itemId)` | `PATCH /grocery-lists/items/{itemId}/toggle` |

### 7.2 Wire `GroceryScreen`

- List of lists → `getGroceryLists()`.
- Items within a list → `getGroceryList(id)`.
- Checkbox → `toggleItem()`.
- Add item → `addItem()`.
- Swipe delete → `deleteItem()`.
- Multi-list → `createGroceryList()` / `deleteGroceryList()`.

---

## Phase 8 — Pantry Integration

### 8.1 Create `PantryRepository`

| Method | Backend Endpoint |
|--------|-----------------|
| `getPantryItems()` | `GET /pantry/items` |
| `addPantryItem(item)` | `POST /pantry/items` |
| `getPantryItem(id)` | `GET /pantry/items/{id}` |
| `updatePantryItem(id, item)` | `PUT /pantry/items/{id}` |
| `deletePantryItem(id)` | `DELETE /pantry/items/{id}` |
| `getExpiringItems(days)` | `GET /pantry/items/expiring?days=7` |
| `getExpiredItems()` | `GET /pantry/items/expired` |

### 8.2 Wire `PantryScreen`

- List → `getPantryItems()`.
- "Expiring soon" badge → `getExpiringItems(7)`.
- Expired section → `getExpiredItems()`.
- Add item via FAB → `addPantryItem()`.
- Edit → `updatePantryItem()`.
- Delete → `deletePantryItem()`.

---

## Phase 9 — Budget Integration

### 9.1 Create `BudgetRepository`

| Method | Backend Endpoint |
|--------|-----------------|
| `getBudget()` | `GET /budget` |
| `setBudget(monthlyLimit)` | `PUT /budget` |
| `recordSpending(amount, category)` | `POST /budget/spend` |
| `getBudgetAnalytics()` | `GET /budget/analytics` |

### 9.2 Wire `BudgetScreen`

- Display current limit/spent → `getBudget()`.
- Edit limit → `setBudget()`.
- Add spending → `recordSpending()`.
- Charts → `getBudgetAnalytics()` response.

---

## Phase 10 — Notification Integration

### 10.1 Create `NotificationRepository`

| Method | Backend Endpoint |
|--------|-----------------|
| `getNotifications(page, size)` | `GET /notifications` |
| `markAsRead(notificationId)` | `PATCH /notifications/{id}/read` |
| `markAllAsRead()` | `POST /notifications/read-all` |
| `deleteNotification(id)` | `DELETE /notifications/{id}` |

### 10.2 Wire notification bell

- Badge count → `getNotifications()` length of unread.
- Notification panel → list from `getNotifications()`.
- Tap → `markAsRead()`.
- Swipe → `deleteNotification()`.

---

## Phase 11 — Recommendation Integration

### 11.1 Create `RecommendationRepository`

| Method | Backend Endpoint |
|--------|-----------------|
| `getRecommendations()` | `GET /recommendations` |
| `submitFeedback(recipeId, liked)` | `POST /recommendations/feedback` |

### 11.2 Wire home screen

- Replace "For You" section with `getRecommendations()`.
- Thumbs up/down → `submitFeedback()`.

---

## Phase 12 — Error Handling & Polish

### 12.1 Global error handling

**Dio interceptor** already logs errors. Add:

```dart
class _ErrorHandlerInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 500) {
      // show generic error snackbar
    }
    if (err.type == DioExceptionType.connectionTimeout) {
      // show "no connection" + retry
    }
    handler.next(err);
  }
}
```

### 12.2 Loading states

All providers should expose:
- `bool isLoading`
- `String? errorMessage`
- `AsyncValue<T>` pattern (Riverpod `AsyncNotifier`)

### 12.3 Offline resilience

- Cache last successful response in `SharedPreferences`/`Hive`.
- On network error, serve cached data with a subtle banner: "Offline — showing cached data".
- Retry button on providers.

---

## Implementation Order & Dependencies

```
Phase 1 (Auth)           → no deps, must go first
Phase 2 (Infrastructure) → no deps, parallel with Phase 1
Phase 3 (Preferences)    → depends on Auth (needs token)
Phase 4 (Profile)        → depends on Auth
Phase 5 (Recipes)        → depends on Auth, partly independent
Phase 6 (Meal Plan)      → depends on Recipes, Preferences
Phase 7 (Grocery)        → depends on Meal Plan (auto-generation)
Phase 8 (Pantry)         → independent, can be parallel with 5-7
Phase 9 (Budget)         → independent, can be parallel with 5-7
Phase 10 (Notifications) → depends on Auth
Phase 11 (Recommends)    → depends on Preferences, Recipes
Phase 12 (Polish)        → continuous throughout
```

## New Files to Create (27 total)

```
lib/core/services/secure_storage_service.dart
lib/core/network/api_response.dart
lib/core/repositories/base_repository.dart
lib/core/repositories/auth_repository.dart
lib/core/repositories/preference_repository.dart
lib/core/repositories/profile_repository.dart
lib/core/repositories/recipe_repository.dart
lib/core/repositories/meal_plan_repository.dart
lib/core/repositories/grocery_repository.dart
lib/core/repositories/pantry_repository.dart
lib/core/repositories/budget_repository.dart
lib/core/repositories/notification_repository.dart
lib/core/repositories/recommendation_repository.dart
lib/features/auth/providers/auth_provider.dart
lib/features/auth/providers/auth_state.dart
lib/shared/models/user.dart
lib/shared/models/recipe.dart
lib/shared/models/meal_plan.dart
lib/shared/models/grocery_list.dart
lib/shared/models/pantry_item.dart
lib/shared/models/budget.dart
lib/shared/models/notification.dart
lib/shared/models/preferences.dart (update EditablePreferences)
lib/shared/models/api_error.dart
```

## Files to Modify (10+)

```
lib/core/network/api_client.dart         — real auth interceptor
lib/features/auth/screens/login_screen.dart      — wire to AuthNotifier
lib/features/auth/screens/signup_screen.dart     — wire to AuthNotifier
lib/features/auth/screens/forgot_password_screen.dart — wire to AuthRepository
lib/features/preferences/screens/food_preferences_screen.dart — wire to PreferenceRepository
lib/features/profile/providers/profile_provider.dart — add API sync
lib/features/profile/screens/profile_screen.dart — add API calls
lib/features/plan/screens/plan_screen.dart       — replace demo_data
lib/features/grocery/screens/grocery_screen.dart — replace demo_data
lib/features/pantry/screens/pantry_screen.dart   — replace demo_data
lib/features/budget/screens/budget_screen.dart   — replace demo_data
lib/shared/models/demo_data.dart       — deprecate, keep as fallback
lib/app/router/app_router.dart         — add auth redirect based on AuthNotifier
```

---

## Final Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                     UI Layer (Screens)                   │
│  Auth / Home / Plan / Grocery / Pantry / Budget / Profile│
└──────────────────────┬──────────────────────────────────┘
                       │ reads
┌──────────────────────▼──────────────────────────────────┐
│               Provider Layer (Riverpod)                  │
│  AuthNotifier | ProfileNotifier | PreferencesNotifier    │
│  MealPlanProvider | GroceryProvider | PantryProvider     │
│  BudgetProvider | RecipeProvider | NotificationProvider  │
└──────────────────────┬──────────────────────────────────┘
                       │ calls
┌──────────────────────▼──────────────────────────────────┐
│             Repository Layer (Data Access)               │
│  AuthRepo | ProfileRepo | PrefRepo | RecipeRepo         │
│  MealPlanRepo | GroceryRepo | PantryRepo | BudgetRepo   │
│  NotificationRepo | RecommendationRepo                   │
└──────────────┬───────────────────────┬──────────────────┘
               │ primary               │ fallback
┌──────────────▼──────────┐  ┌─────────▼────────────────┐
│    ApiClient (Dio)       │  │  LocalStorage            │
│  → Backend :8081/api/v1  │  │  (SharedPreferences/Hive)│
│  → JWT interceptor       │  │  → offline cache         │
│  → 401 refresh + retry   │  │  → demo_data fallback    │
└──────────────────────────┘  └──────────────────────────┘
```

---

**Estimated effort:** ~10–14 focused coding sessions, starting with Phase 1 (Auth) which is the critical dependency for everything else. Each phase after auth is ~1–2 sessions depending on screen complexity.
