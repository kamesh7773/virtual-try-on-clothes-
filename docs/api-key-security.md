# Decart API key security

**Status:** open, deliberately deferred.
**Deferred on:** 2026-09-02, by project owner. Current builds go to internal
company testers only, and the risk was accepted for that audience.

---

## How the key travels today

1. `.env.development` and `.env.staging` hold the real `dct_*` key. Both are
   gitignored. `.env.example` carries a placeholder and is tracked.
2. `flutter_dotenv` loads them, so they are declared under `assets:` in
   `pubspec.yaml` and ship **inside the app bundle**.
3. `Env.decartApiKey` reads the value.
4. `SessionViewModel.prepare()` resolves a key: secure storage first, then
   `Env.decartApiKey` as fallback.
5. The key is passed to `DecartSessionService.initialize()`, across the
   `livelook/decart` method channel, into the native SDK config on both
   platforms.
6. `.env.production` ships with `DECART_API_KEY=` blank on purpose, so a
   release build has no key at all.

## The risk

A bundled `.env` file is **not encrypted**. Anyone with the IPA or APK can
unzip it and read the key in plain text. No jailbreak or reverse engineering
is needed.

A `dct_*` key is a full account credential. It can mint client tokens and
spend credits. Decart's own documentation states:

> In production, never expose your permanent API key (`dct_*`) to the browser.

**Blast radius:** credit spend on our Decart account. No end-user data is
exposed, because the app stores none.

## When this must be fixed

Any build that leaves the internal tester group. Specifically:

- Public TestFlight, or an external TestFlight group
- Play Store open or closed testing
- App Store release
- Handing an APK or IPA to a client or partner

## The intended fix: a token endpoint

The app is already scaffolded for this and the wiring is unused, not missing:

| Piece | Location | State |
| --- | --- | --- |
| `Env.tokenEndpoint`, `Env.hasTokenEndpoint` | `lib/core/config/env.dart` | Present, returns null (`TOKEN_ENDPOINT=` blank everywhere) |
| `ApiEndpoints.createClientToken` = `/v1/client/tokens` | `lib/core/constants/api_endpoints.dart` | Present, unused |
| `ApiEndpoints.apiKeyHeader` = `x-api-key` | same | Present |
| Dio API key interceptor | `lib/core/services/api_client.dart` | Present |

**Target flow**

```
app  ->  our backend /token  ->  Decart POST /v1/client/tokens  (x-api-key)
     <-  short-lived token   <-  200 { token, expires_at }
app  ->  DecartSessionService.initialize(apiKey: <client token>)
```

The long-lived key then lives only on our server and never enters the binary.

### Verified facts

- `POST https://api.decart.ai/v1/client/tokens` with an `x-api-key` header
  returns 200. Confirmed by hand during the port.
- A client token **cannot** mint another token. That request returns 403.
- Client tokens have a **10-minute TTL**, and active WebRTC sessions keep
  running after the token expires.
- Our sessions are capped at 60 seconds
  (`SessionViewModel.autoDisconnectSeconds`), so one token comfortably covers
  an entire session with no mid-session refresh logic.

### Open question, resolve before designing further

**Do the native SDKs accept a client token in their `apiKey` field?**

The Decart docs do not say. The published initialisers are:

```kotlin
DecartClientConfig(apiKey = "your-api-key")
```
```swift
DecartConfiguration(apiKey: "your-api-key-here")
```

Both name the field `apiKey`, and nothing documents whether a `dct_` key is
required or whether an ephemeral token is also accepted. The web SDK clearly
takes tokens; the mobile SDKs are unconfirmed.

This must be answered by a device spike before any backend work, because a
"no" changes the whole design. Fallbacks if tokens are rejected: proxy the
signalling handshake through our own server, or raise it with Decart support.

**Lead worth starting from.** The mint response is
`{ apiKey, token, expiresAt, permissions, constraints }`. It carries an
`apiKey` field of its own, which suggests the intended client flow is to feed
`response.apiKey` into the SDK's `apiKey` parameter rather than `response.token`.
Try that combination first in the spike.

## Work items, in order

1. **Spike (1-2 h).** Mint a client token by hand, pass it as `apiKey` on iOS
   and Android, confirm a session connects. Everything below depends on this.
2. **Backend endpoint.** Any host. It calls Decart with the real key and
   returns the token. It must **not** be publicly open: without app-level auth
   or rate limiting it becomes a free token faucet against our credits.
3. **Dart side.** Add a `TokenRepository`, and make `SessionViewModel.prepare()`
   prefer `Env.tokenEndpoint` over `Env.decartApiKey` when it is set.
4. **Refresh policy.** Mint per session start, not per app launch. A token
   minted at launch can be well past its 10 minutes by the first Try On tap.
5. **Blank the key** out of `.env.development` and `.env.staging`.
6. **Rotate the key.** See below.

## Key rotation

The current key has shipped inside development and staging builds that were
handed to testers. Once the token endpoint is live, treat that key as
compromised and rotate it in the Decart console, regardless of whether any
misuse is observed. Rotating is the only way to invalidate copies already
sitting in installed builds.
