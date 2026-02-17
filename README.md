# BackstageCodeAssignment

An iOS app that displays searchable, selectable lists of **Movies** and **Restaurants** fetched from a remote API.

---

## Architecture Overview

The app follows a **Model-View-ViewModel (MVVM)** pattern built on UIKit. A reusable base layer — `SearchableTableViewModel` and `SearchableTableViewController` — handles all generic list behaviour (searching, filtering, selection, empty state). Feature-specific subclasses extend this base to add their own data loading and cell rendering. This should allow us to expand for new data type with relative ease - we just need to create a new model that adheres to the Searchable protocol and implement new subclasses for `SearchableTableViewModel` and `SearchableTableViewController` to display the data.

```
┌─────────────────────────────────────────────────────────────────┐
│                          UI Layer                               │
│                                                                 │
│   SearchableTableViewController  (base, UITableViewController) │
│          ├── MoviesViewController                               │
│          └── RestaurantsViewController                          │
└────────────────────────────┬────────────────────────────────────┘
                             │ owns
┌────────────────────────────▼────────────────────────────────────┐
│                       ViewModel Layer                           │
│                                                                 │
│         SearchableTableViewModel  (base, @MainActor)            │
│                ├── MovieTableViewModel                          │
│                └── RestaurantTableViewModel                     │
└────────────────────────────┬────────────────────────────────────┘
                             │ calls
┌────────────────────────────▼────────────────────────────────────┐
│                      Networking Layer                           │
│                                                                 │
│                    APIManager  (actor)                          │
└────────────────────────────┬────────────────────────────────────┘
                             │ decodes into
┌────────────────────────────▼────────────────────────────────────┐
│                        Model Layer                              │
│                                                                 │
│        Movie        Restaurant        Cuisine                   │
│           └──────────── Searchable (protocol) ──────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Layer Breakdown

### Models

| Type | Description |
|---|---|
| `Movie` | Codable struct: `id`, `title`, `genre`, `director`, `year` |
| `Restaurant` | Codable struct: `id`, `name`, `city`, `priceLevel`, `rating` |
| `Cuisine` | Codable struct: `name`, list of `Restaurant`s, optional `filteredRestaurants` |
| `CuisineResponse` | Top-level decode wrapper for the restaurants endpoint |

All model types conform to the **`Searchable`** protocol:

```swift
protocol Searchable {
    func filtering(by query: String) -> Searchable?
}
```

`filtering(by:)` returns a (possibly mutated) copy of the item if it matches the query, or `nil` if it does not. This makes filtering a single `compactMap` call with no branching in the view layer. `Cuisine` has special behaviour: when the cuisine name itself matches, all its child restaurants are included; otherwise only matching restaurants are surfaced.

---

### Networking — `APIManager`

`APIManager` is a Swift **`actor`**, ensuring all network calls are data-race safe. It is accessed via a shared singleton.

- `getMovieList()` → `[Movie]` — decodes a flat JSON array
- `getCuisineList()` → `[Cuisine]` — decodes via `CuisineResponse` wrapper

Both methods use `URLSession` async/await and a shared `JSONDecoder` configured for snake_case keys and ISO 8601 dates.

---

### ViewModel Layer

#### `SearchableTableViewModel` (base)

Marked `@MainActor` so all state mutations are safe to observe from the UI layer.

| Property / Method | Purpose |
|---|---|
| `items` | The full unfiltered data set. Setting it triggers `applyFilter()`. |
| `filteredItems` | The currently displayed subset after filtering. |
| `searchQuery` | The live search string. Setting it triggers `applyFilter()`. |
| `title` | Navigation bar title, set by subclasses. |
| `searchPlaceholder` | Search bar hint text, set by subclasses. |
| `selectionType` | `.Single` or `.Multiple`, controls tap behaviour. |
| `selectedIndexPaths` | Tracks selected rows as a `Set<IndexPath>`. |
| `hasNoResults` | `true` when a query is active but `filteredItems` is empty. |
| `applyFilter()` | Runs `compactMap { $0.filtering(by:) }` over `items`. |
| `toggleSelection(at:)` | Inserts or removes an index path from `selectedIndexPaths`. |
| `itemForIndexPath(_:)` | Returns the `Searchable` item at a given index path. Overridable for sectioned data. |
| `getItems()` | Async data-loading hook, overridden by subclasses. |

#### `MovieTableViewModel`
- Sets `selectionType = .Single`
- Fetches from `APIManager.shared.getMovieList()`

#### `RestaurantTableViewModel`
- Sets `selectionType = .Multiple`
- Fetches from `APIManager.shared.getCuisineList()`
- Overrides `itemForIndexPath(_:)` to navigate the two-level `Cuisine → Restaurant` structure

---

### View Layer

#### `SearchableTableViewController` (base)

A `UITableViewController` subclass that owns a `SearchableTableViewModel` and wires it to the UI.

| Responsibility | Implementation |
|---|---|
| Search | `UISearchController` with `UISearchResultsUpdating`; writes to `viewModel.searchQuery` |
| Empty state | Sets `tableView.backgroundView` to a "No results found" label via `updateEmptyState()` |
| Single selection | Calls `itemForIndexPath` and shows an alert with the item name |
| Multi-select | Toggling checkmarks via `toggleSelection`; a "Done" bar button appears when items are selected |
| Data loading | Calls `viewModel.getItems()` inside a `Task`, then reloads the table |
| View model setup | `configureViewModel()` is called in `viewDidLoad` and overridden by subclasses to inject the correct view model type |

#### `MoviesViewController`
- Overrides `configureViewModel()` to install a `MovieTableViewModel`
- Overrides `cellForRowAt` to render `title`, `genre`, `year`, and `director`

#### `RestaurantsViewController`
- Overrides `configureViewModel()` to install a `RestaurantTableViewModel`
- Overrides `numberOfSections` / `titleForHeaderInSection` to render cuisine groups
- Overrides `cellForRowAt` to render `name`, `city`, `priceLevel`, and `rating`
- Reads from `cuisine.filteredRestaurants` or `cuisine.restaurants` to respect per-cuisine filtering

---

## Data Flow

```
User types in search bar
        │
        ▼
UISearchResultsUpdating.updateSearchResults
        │
        ▼
viewModel.searchQuery = text          ← didSet
        │
        ▼
viewModel.applyFilter()
        │  compactMap { $0.filtering(by: query) }
        ▼
viewModel.filteredItems updated
        │
        ▼
tableView.reloadData() + updateEmptyState()
```

---

## File Structure

```
BackstageCodeAssignment/
├── Models/
│   ├── Movie.swift
│   └── Restaurant.swift          (Restaurant, Cuisine, CuisineResponse)
├── Protocols/
│   └── Searchable.swift
├── Networking/
│   └── APIManager.swift
├── ViewModels/
│   ├── SearchableTableViewModel.swift
│   ├── MovieTableViewModel.swift
│   └── RestaurantTableViewModel.swift
└── Views/
    ├── SearchableTableViewController.swift
    ├── MoviesViewController.swift
    └── RestaurantsViewController.swift
```

---

## Key Design Decisions

- **`Searchable.filtering(by:)` returns an optional self** — rather than a separate boolean predicate, each model owns its filtering logic and can return a structurally modified copy (e.g. `Cuisine` with a narrowed `filteredRestaurants` list). This keeps all filter logic co-located with the model.
- **`APIManager` is an `actor`** — eliminates data races on shared networking state without any manual locking.
- **`SearchableTableViewModel` is `@MainActor`** — all property mutations happen on the main thread by default, so the view controller never needs to dispatch back to main after an `await`.
- **Subclass-and-override for feature screens** — `configureViewModel()` and `getItems()` are the two override points, keeping boilerplate in the base class and feature code minimal.

## Building and Running

The project does not utlize any third party libraries so building it is just a matter of selecting the BackstageCodingAssignment target from the dropdown, selecting a device and pressing the Run button. The app will run on both iPhone and iPads in either landscape or portrait orientation.

## Trade-offs

I considered refining the APIManager further so that it would have a single getData(from endpoint:URL) function that would return either an array of Movies or an array of Cuisine objects, using a Generic type. I was hoping to use this function from within the SearchableTableViewModel getItems() function, since the overridden getItems() functions in the MovieTableViewModel and RestaurantTableViewModel are so similar. However, I decided against this approach for two reasons:
- I find the use of generic type can made code more difficult to understand for mid-level developers
- The structure of the data being returned by the two endpoint was too different - /movies returned a flat array whereas /restarants had to be parsed for the `cuisines` data. This made using a single function to parse both more trouble than I thought it was worth.

Another thing to note is that when the user has selected items in the multi-selection restaurants list, using the search box will clear the users selections. This is because we store our selections as IndexPaths which will change when the user filters on the data. I was unable to find a reliable way to store a Set of Searchable objects so I compromised with this.

Also, due to time constraints I was unable to implement any tests or SwiftUI interfaces.

## Project tracking

I used a Jira board to track my work on this project, it can be found at https://gingermcninja.atlassian.net/jira/software/projects/BAC/boards/243
