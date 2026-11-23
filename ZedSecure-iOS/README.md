# ZedSecure iOS Port

Native Swift iOS port foundation for the Android/desktop ZedSecure project.

## Run core tests
On macOS with Xcode Command Line Tools or Swift installed:

```sh
cd ZedSecure-iOS
swift test
```

## Implemented and tested
- Normalized Swift server model and protocol URI aliases.
- VLESS-style authority parsing, Trojan password parsing, IPv6 host normalization.
- VMess base64 JSON endpoint/UUID/name extraction.
- Shadowsocks base64 payload extraction.
- XCTest coverage for the above cases.

## Not yet implemented
- Full transport/TLS/REALITY query decoding and engine-specific config generation.
- All Shadowsocks SIP002 variants (including plugin options and every URL-safe form).
- Subscription formats, QR scanning, profile persistence and server management UI.
- sing-box, Xray, WireGuard/AmneziaWG iOS engine integration.
- Network Extension Packet Tunnel target, entitlement, provisioning, signing and IPA.

Android AAR/JNI binaries cannot be linked directly into iOS. A functional VPN
requires iOS-compatible engine binaries plus the Apple Network Extension
capability and a correctly provisioned Packet Tunnel extension. Free Apple ID
sideloading does not itself grant that entitlement.
