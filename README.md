# Peego — Pregnant Washroom Finder

Find clean, safe and accessible washrooms — wherever you are. 💜

A SwiftUI iOS app for expecting moms to quickly locate nearby washrooms, check
real reviews and accessibility amenities, and contribute new places to the
community map.

## Features

- **Nearby Washrooms** — home list of the closest washrooms, sorted by distance
- **Map Search** — interactive map with purple pins, search, and a quick-info
  card for the selected place
- **Accessibility Filters** — filter by Wheelchair Accessible, Baby Change
  Table, Gender Neutral, Free to Use, Family Friendly, and max distance
- **Real Reviews** — star breakdown, review list, and an add-review flow
- **Add & Share** — submit a new washroom with a map-tap location picker,
  amenity chips, rating, and an optional photo
- **Favorites** — heart any washroom to save it
- **Work Offline** — connectivity is monitored and an offline notice appears
  with cached washrooms still available
- **Profile** — My Reviews, My Added Places, Settings, Offline Maps, About
- **Light & Dark UI** — brand palette adapts to both appearances

## Structure

All app code lives in `to/` (target `to`, displayed as **Peego**):

| File | Purpose |
| --- | --- |
| `toApp.swift` | App entry point |
| `MainTabView.swift` | Root view, onboarding gate, tab bar |
| `Theme.swift` | Brand colors, gradients, button styles |
| `Models.swift` | `Washroom`, `Review`, `Amenity`, filter settings |
| `SampleData.swift` | Seeded washrooms & reviews (downtown Vancouver) |
| `WashroomStore.swift` | Observable store, persistence, network monitor |
| `Components.swift` | Logo, star ratings, chips, list rows |
| `OnboardingView.swift` | Splash / get-started screen |
| `HomeView.swift` | Nearby washrooms list |
| `MapScreen.swift` | Find Washrooms map |
| `FilterView.swift` | Amenity + distance filter sheet |
| `WashroomDetailView.swift` | Place details, directions, add review |
| `ReviewsView.swift` | Ratings summary, reviews, add-review sheet |
| `AddWashroomView.swift` | Add a Washroom form |
| `FavoritesView.swift` | Saved washrooms |
| `ProfileView.swift` | Profile menu and subpages |
| `OfflineModeView.swift` | Offline mode notice |

## Notes

- User position is simulated (downtown Vancouver) so distances work in the
  simulator without location permissions.
- Favorites, user reviews, and user-added places persist via `UserDefaults`.
- Requires Xcode 26 (the project uses file-system-synchronized groups).

## Running

Open `to.xcodeproj` in Xcode, select an iPhone simulator, and run.
