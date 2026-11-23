# Android → iOS Port Audit (source-grounded)

Source inspected: `CluvexStudio/ZedSecure` default branch `main`.
Target work branch: `LongKey2020/zedsecure` → `ios-sideload-foundation`.

## 1. Architecture findings

- The shared module is Kotlin Multiplatform, but its Gradle targets currently define Android and JVM desktop only. There is no iOS target or `iosMain` source set in the inspected build configuration.
- The Android app uses Kotlin/Compose and an Android `VpnService` implementation. Android service code cannot be compiled as an iOS Packet Tunnel Provider.
- The shared domain/UI source is substantial, but the current Compose UI is not SwiftUI. A native SwiftUI UI requires a port or a separately planned Kotlin/Native + Compose Multiplatform iOS migration.
- The Android native engine bridges include sing-box (libbox) and Xray (libv2ray); these Android bindings are not iOS binaries and cannot be linked directly into an iOS app.

## 2. Protocol and profile inventory found in source

### Standard server protocol enum
- VLESS
- VMess
- Trojan
- Shadowsocks
- SOCKS
- HTTP
- WireGuard
- AmneziaWG
- Hysteria
- MASQUE

The source maps URI schemes including `vless`, `vmess`, `trojan`, `ss` / `shadowsocks`, `socks` / `socks5` / `socks4` / `socks4a`, `http` / `https`, `wireguard` / `wg`, `awg` / `amneziawg`, `hysteria` / `hysteria2` / `hy2`, and `masque`.

### Additional profile source types
- Link and raw JSON profiles
- Sealed ZSX profiles
- Psiphon
- DNS Tunnel and Master DNS
- Tor
- SSH
- SNI Spoof
- OpenConnect
- IKEv2
- Proxy Chain and Cross Chain
- Auto Select
- Sing-box JSON and Sing-box config

This is an inventory of model types, not proof that every engine can be ported with equal effort or is currently available on iOS.

## 3. Shared configuration model fields

The inspected `ServerConfig` model carries endpoint, credentials, transport, TLS/security, WireGuard/AmneziaWG, DNS, allowed IPs, MTU, keepalive, bandwidth, and Sing-box selection fields. Transport options include network, host, path, gRPC service name, QUIC options, XHTTP extras, KCP settings, headers, and related values. Security fields include TLS/REALITY parameters, SNI, fingerprint, ALPN, public key, short ID, ECH, certificate-name verification, cipher suites, and allow-insecure.

The `VpnProfile` model additionally stores profile source, subscription ID, ping, country, traffic counters, lock state, and notes.

## 4. Feature parity plan

| Feature group | Android source evidence | iOS port approach | Status |
|---|---|---|---|
| SwiftUI app shell | Compose app and shared screens | Native SwiftUI | Foundation only |
| Profile model | `VpnProfile`, `ServerConfig` | Codable Swift models | Partial foundation |
| Link parsing | `ConfigParser`, `ShareLink` | Port parser per scheme with fixtures | Not implemented |
| Profile import/export | Link, JSON, sealed ZSX, share-link models | Files, share sheet, URL schemes | Not implemented |
| VPN lifecycle | Android `VpnService` / `ZedVpnService` | NetworkExtension Packet Tunnel | Scaffold only |
| sing-box engine | Android libbox integration | iOS-compatible sing-box build + Swift bridge | Not implemented |
| Xray engine | Android libv2ray integration | iOS-compatible Xray build + bridge | Not implemented |
| WireGuard / AmneziaWG | Protocol models and Android engine paths | iOS-compatible tunnel implementation; validate AWG-specific support separately | Not implemented |
| Psiphon / Tor / SSH / DNS tunnel / OpenConnect / IKEv2 | Dedicated profile types and Android controllers | Separate feasibility and native-engine work per feature | Not implemented |
| Routing / per-app proxy | Android settings and VPN integration | Map only supported NetworkExtension capabilities; some Android semantics will differ | Not implemented |
| QR scan | Android camera/QR implementation | AVFoundation + Vision or supported scanner | Not implemented |
| Settings / themes / localization | Large shared settings model and Compose screens | SwiftUI settings model and UI | Not implemented |
| Traffic / logs / diagnostics | Engine callbacks and Android service UI | Engine callbacks + NetworkExtension telemetry | Not implemented |
| Widgets / quick settings / boot receivers | Android manifest services/receivers | No direct equivalent; redesign using iOS capabilities | Not parity-equivalent |

## 5. Blocking platform constraints

1. A functional packet tunnel needs the Apple Network Extension capability, a Packet Tunnel Provider target, matching bundle identifiers, provisioning, and appropriate signing. The source scaffold currently does not provide these.
2. The free Apple ID / Feather / ESign installation route does not itself grant Network Extension entitlement. Do not assume a sideloaded app can run a real VPN tunnel.
3. The Android AAR/JNI/native engine packages must not be treated as reusable iOS frameworks. iOS-specific engine binaries and bridge code must be built and validated.
4. The current iOS folder is a starter scaffold, not a runnable or feature-complete VPN implementation.

## 6. Recommended implementation order

1. Complete the Swift data layer and parser tests for the source protocol/model formats.
2. Decide engine strategy: sing-box first for its broad protocol coverage, then assess Xray and protocol-specific engines. Verify upstream iOS build support, licenses, and required APIs before integrating.
3. Build the Packet Tunnel Provider and NetworkExtension settings lifecycle.
4. Implement profile storage, import/export, subscription refresh, QR scanning, and server management.
5. Add connection telemetry, logs, routing controls, and settings.
6. Audit every Android-only feature and document intentional iOS differences.
7. Build and test on macOS/Xcode with a valid Apple development provisioning setup and Network Extension entitlement.

## 7. Files to use as primary references

- `shared/src/commonMain/.../domain/config/ServerConfig.kt`
- `shared/src/commonMain/.../domain/config/VpnProfile.kt`
- `shared/src/commonMain/.../domain/config/ShareLink.kt`
- `shared/src/commonMain/.../domain/model/AppSettings.kt`
- `shared/src/commonMain/.../domain/model/ConnectionState.kt`
- `app/src/main/.../core/ZedVpnService.kt`
- `app/src/main/.../core/SingBoxEngine.kt`
- `app/src/main/.../core/XrayController.kt`
- `shared/build.gradle.kts`

---
This audit deliberately separates features confirmed by inspected source from iOS implementation assumptions. It does not claim functional VPN connectivity.
