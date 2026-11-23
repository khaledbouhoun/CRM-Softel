# Security Policy

## Supported versions

Only the latest release built from `main` receives security fixes.

## Reporting a vulnerability

**Do not open a public GitHub issue for security problems.**

Report privately through GitHub's
[private vulnerability reporting](https://github.com/khaledbouhoun/CRM-Softel/security/advisories/new)
for this repository, or contact the maintainer
([@khaledbouhoun](https://github.com/khaledbouhoun)) directly. Include:

- the affected version or commit,
- steps to reproduce,
- the impact you observed.

Please allow time for a fix before any disclosure.

## Security model

This client is designed for use **inside a trusted company LAN**. Deployers
should understand these properties:

| Topic | Current behaviour |
|---|---|
| Authentication | None in the client. All workstations have the same access to the API. |
| Identity / audit | The Windows user name is sent as `X-Employee-Name` on write requests. It is a label and can be spoofed, so it does not authorize anything. |
| Transport | Plain HTTP by default (`http://<server>:8000/api/v1`). HTTPS works if the server provides it: just enter an `https://` URL. |
| Local data | Only preferences (server URL, timeout, theme, language) are stored, per Windows user, with `get_storage`. No business data or credentials are cached. |
| Secrets in repo | None. The client needs no API keys or tokens. |
| Downloads | Attachments and release installers are saved only where the user chooses in a native file dialog. |

### Deployment recommendations

- Expose the API **only on the internal network**. Firewall the API port from
  the internet.
- Prefer HTTPS on the server if the LAN is shared or includes Wi-Fi guests.
- Enforce access control on the backend (network ACLs, or authentication if
  the API gains it). Don't rely on `X-Employee-Name` for authorization.
- Keep the backend and the Flutter SDK up to date.
