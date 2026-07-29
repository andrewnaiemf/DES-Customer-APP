# iOS DEV CI setup (no Mac required on your side)

Goal: **DEV** builds only → downloadable **IPA** + **TestFlight** (not App Store production).

## Apple identifiers

| Item | Value |
|------|--------|
| Team ID | `Z8LQP638P4` |
| App Bundle ID | `com.DES.DESUserApp` |
| Widget Bundle ID | `com.DES.DESUserApp.widget` |
| ASC Key ID | `6SP3K86KWQ` |
| ASC Issuer ID | `db04de63-863e-404d-8c33-c599ec8d27f1` |

In [Apple Developer → Identifiers](https://developer.apple.com/account/resources/identifiers/list), create the Widget App ID if missing:
`com.DES.DESUserApp.widget` (App → continue → enable Push Notifications if prompted).

## Option A — Codemagic (recommended)

1. Go to [codemagic.io](https://codemagic.io) → sign in with **GitHub**
2. Add application → select `abanoubsam99/DES-Customer-APP`
3. **Team settings → Integrations → App Store Connect**  
   - Add API key name: `des_asc_api` (must match `codemagic.yaml` → `integrations.app_store_connect`)
   - Key ID / Issuer ID / upload `AuthKey_6SP3K86KWQ.p8`
4. **Code signing** → allow Codemagic to manage certificates for both bundle IDs above
5. Open workflow **iOS Dev (TestFlight + IPA)** → Start build on branch `Des-v2`
6. When done:
   - Download IPA from build artifacts
   - Install from TestFlight after processing (~5–15 min)

## Option B — GitHub Actions

1. Repo → **Settings → Secrets and variables → Actions** → add:

| Secret | Value |
|--------|--------|
| `APP_STORE_CONNECT_KEY_ID` | `6SP3K86KWQ` |
| `APP_STORE_CONNECT_ISSUER_ID` | `db04de63-863e-404d-8c33-c599ec8d27f1` |
| `APP_STORE_CONNECT_PRIVATE_KEY` | entire `.p8` file text including `BEGIN/END` |
| `APPLE_TEAM_ID` | `Z8LQP638P4` |

2. **Actions** → **iOS Dev (IPA + TestFlight)** → **Run workflow** (branch `Des-v2`)
3. Download IPA from the run’s Artifacts
4. TestFlight build appears under App Store Connect → TestFlight

## After install on iPhone XR

1. Open app → trigger order status notification  
2. **Lock the phone** → look for Live Activity card on Lock Screen  
3. XR has no Dynamic Island — Lock Screen only  

## Security

Never commit `AuthKey_*.p8` to git. It must stay in Codemagic / GitHub Secrets only.
