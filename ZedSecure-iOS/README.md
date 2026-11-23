# ZedSecure iOS Port

This directory contains the native iOS port foundation. The Swift Package covers
a platform-neutral configuration model and a deliberately limited URI-authority
parser. It does **not** provide a working VPN connection.

## Run core tests

On a Mac with Xcode Command Line Tools:

```sh
cd ZedSecure-iOS
swift test
```

## Implementation status

- Swift configuration model and protocol-scheme aliases: implemented.
- Basic endpoint URI parsing and unit tests: implemented.
- VMess JSON/base64 and Shadowsocks encoded-link decoding: not implemented.
- SwiftUI app shell and Packet Tunnel Provider: scaffold only.
- sing-box, Xray, WireGuard/AmneziaWG engine integration: not implemented.
- Network Extension entitlement, provisioning, and signed IPA: not configured.

The Android AAR/JNI libraries cannot be linked directly into an iOS app. Engine
integration requires iOS-compatible binaries and a real Network Extension
Packet Tunnel target. A free Apple ID or sideloading tool does not grant the
Network Extension entitlement needed for a functional VPN tunnel.
