# Building and deploying the Windows client

## 1. Versioning

The version is defined in **two places**. Keep them in sync:

| File | Field |
|---|---|
| `pubspec.yaml` | `version: 1.0.0+1` (name + build number, embedded in the `.exe`) |
| `installer/CRM-Softel.iss` | `#define MyAppVersion "1.0.0"` |

You can also override the version at build time with
`--build-name` / `--build-number`.

## 2. Release build

```bash
flutter clean            # optional, for a fully fresh build
flutter pub get
flutter test
flutter build windows --release
```

The output folder is `build\windows\x64\runner\Release\`. It contains
`softel_crm.exe`, the Flutter DLLs, plugin DLLs and `data\`. The whole folder
is required, not just the `.exe`.

## 3. Installer (Inno Setup)

1. Install [Inno Setup 6](https://jrsoftware.org/isinfo.php).
2. Open `installer/CRM-Softel.iss` and compile it (or run
   `ISCC.exe installer\CRM-Softel.iss`).
3. The installer is written to `installer\Output\CRM-Softel-Setup.exe`. That
   folder is git-ignored.

What the installer does:

- installs **per user**, with no admin rights (`PrivilegesRequired=lowest`),
  into `%LOCALAPPDATA%\Programs\CRM - Softel`;
- supports x64 only;
- adds a Start-menu shortcut and an optional desktop shortcut;
- offers to launch the app at the end.

Keep the `AppId` GUID unchanged between releases, so new versions upgrade
the existing installation in place.

## 4. Rolling out to workstations

1. Make sure the backend is reachable from each PC: open
   `http://<server-ip>:<port>/api/v1/health` in a browser.
2. Run `CRM-Softel-Setup.exe` on each workstation.
3. On first launch, enter the server's LAN address in **Settings → Connection**,
   test it, then save. Never use `localhost` on employee PCs.
4. Settings are stored per Windows user. They survive upgrades.

You can also publish new client versions through the **Releases** module of
the CRM itself, which uploads the installer to the server for download.

## 5. Troubleshooting

| Symptom | Likely cause |
|---|---|
| "Server unreachable" in the top bar | Wrong IP or port, server down, or the firewall blocks the port. |
| "Response is not JSON" error | The URL points to a web server root instead of `/api/v1`. |
| `/health` returns 503 | The API is running but its database is down. |
| Timeouts on a slow network | Increase the timeout in Settings (up to 120 s). |
