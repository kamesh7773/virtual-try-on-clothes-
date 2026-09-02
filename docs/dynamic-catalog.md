# Dynamic garment catalog

**Status:** proposed, not started. Blocked on one decision: which backend.

**Goal:** add, edit, or remove garments without shipping a new app build.

---

## Where things stand

The catalog is fully bundled:

- `assets/data/catalog.json` holds 8 garments.
- `assets/garments/` holds their images. 2.1 MB total, ~250 KB average.
- `CatalogRepository.fetchGarments()` reads the JSON through `AssetBundle`.

The upside of this is real and worth keeping in some form: the app works with
no network and no credentials.

## What has to change

Four places. Nothing above them moves.

| # | Location | Change |
| --- | --- | --- |
| 1 | `lib/features/try_on/repositories/catalog_repository.dart` | `_bundle.loadString` becomes an HTTP GET |
| 2 | `lib/features/try_on/views/widgets/garment_strip.dart:102` | `Image.asset` becomes a cached network image |
| 3 | `lib/features/try_on/views/widgets/garment_overlay_card.dart:42` | same |
| 4 | `lib/features/try_on/view_models/session_view_model.dart:225` | `_garmentBytes` fetches bytes over the network instead of from the bundle |

`GarmentModel` needs no change at all. Its `image` field is already just a
string; it starts holding a URL instead of an asset key, and `fromJson` is
untouched.

`CatalogRepository` already returns `ApiResponse<List<GarmentModel>>`
specifically so this swap stays local to one method body. Its own doc comment
records that intent.

## Design notes

### Caching is mandatory, not an optimisation

Item 4 is the one that decides whether this feels good or broken.
`_garmentBytes` uploads the **full image** to Decart on every garment switch.
Today that is a local bundle read and effectively instant. Over the network it
becomes a download, and it fires exactly while the user is swiping the strip.

Without a disk cache, every first-time swipe stalls. Sizes are modest, so a
plain cache solves it; there is no need for thumbnails or a CDN transform
step yet.

### Keep an offline fallback

Ship the current 8 garments in the bundle as a fallback and let the remote
list replace them once it loads. Otherwise a first launch with no network
shows an empty screen, and the app loses the "works with no network"
property it has today.

### Free bonus: remote prompt tuning

Prompts live in `catalog.json` alongside the images. Once the catalog is
remote, **prompt fixes ship without a build too**. Given that prompt wording
drives output quality and is tuned by trial, this is arguably worth as much
as the garment updates themselves.

### Prompt rules still apply

Anything added remotely must follow the VTON 3.5 prompting guide, same as the
bundled entries: one action per prompt, canonical region names
(`upper body garment`, `lower body garment`, `outfit`, `footwear`, `hat`,
`necklace`), and only details that are actually visible in the reference
image.

Reference: https://docs.platform.decart.ai/models/realtime/vton-3.5-prompting

## Backend options

| Option | How a garment gets added | Good for | Cost |
| --- | --- | --- | --- |
| **Static hosting** (Cloudflare R2, S3, any static host) | Upload the image, hand-edit `catalog.json` | Simplest possible. No backend code | Lowest |
| **Firebase** (Firestore + Storage) | Add a document from the console, no developer needed | Non-developers managing the catalog | Low |
| **Own API** | Through an admin UI we build | Needed only once there are user accounts, analytics, or per-tester catalogs | Highest |

**Recommendation: Firebase.** The stated goal is changing garments without a
rebuild, and Firebase is the only one of the three where a non-developer can
do it unaided. An own API solves problems this project does not have yet.

## Open decisions

1. Which backend. Everything else waits on this.
2. Will non-developers add garments? If yes, Firebase is effectively decided,
   and a short "how to add a garment" note for them is worth writing.
3. Cache busting. How does the app know the catalog changed? Simplest answer
   is refetch on app resume and rely on HTTP caching headers.

## Estimate

Roughly half a day once the backend is chosen, including the disk cache and
the offline fallback.
