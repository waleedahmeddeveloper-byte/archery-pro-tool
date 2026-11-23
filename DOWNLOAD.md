# Android download checklist

Use **option A** first. Releases (B) often fail on phone networks that block GitHub’s release CDN.

| # | Option | Link | Status (server check) | Notes |
| --- | --- | --- | --- | --- |
| A | **Repo ZIP (recommended)** | [dist/arcus-android.zip](https://github.com/waleedahmeddeveloper-byte/archery-pro-tool/blob/main/dist/arcus-android.zip) → **Download raw file** | Working | Best on phones |
| A2 | Raw ZIP URL | https://github.com/waleedahmeddeveloper-byte/archery-pro-tool/raw/main/dist/arcus-android.zip | Working | Paste into browser |
| B1 | Release ZIP | https://github.com/waleedahmeddeveloper-byte/archery-pro-tool/releases/download/v0.1.1/arcus-android-v0.1.1.zip | Working from servers; may fail on some ISPs | Same bytes as A |
| B2 | Release APK | https://github.com/waleedahmeddeveloper-byte/archery-pro-tool/releases/download/v0.1.1/arcus-release.apk | Working from servers; phones often block `.apk` | Prefer ZIP |
| B3 | Release page | https://github.com/waleedahmeddeveloper-byte/archery-pro-tool/releases/tag/v0.1.1 | Page loads | Expand **Assets** |

## Install steps

1. Download the ZIP (option A).
2. Unzip → you get `arcus-release.apk`.
3. On Android: open the APK → allow **Install unknown apps** for Files/Chrome if asked.
4. Open Arcus.

## What is in the repo vs local only

| File | On GitHub? | Purpose |
| --- | --- | --- |
| `dist/arcus-android.zip` | Yes | Tracked download (~23 MB) |
| `dist/README.md` | Yes | Short instructions |
| `dist/arcus-release.apk` | No (gitignored) | Local build drop only; APK lives *inside* the zip |
| Release assets `v0.1.1` | Yes (Releases) | Backup CDN path |

## Do not use

- Cursor chat artifact paths (`/opt/cursor/artifacts/...`) — not a public download URL.
- The GitHub **blob** page alone without clicking **Download raw file** — that page is HTML, not the ZIP.
