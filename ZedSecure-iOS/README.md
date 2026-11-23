# ZedSecure iOS Foundation

Native SwiftUI foundation for an iOS port of ZedSecure.

## Current scope
- SwiftUI app shell and dashboard
- Server/configuration model and basic URI parsing
- Network Extension Packet Tunnel provider scaffold
- iOS build workflow scaffold

## Important limitations
This is not yet a feature-complete VPN port. The Android app's native engine integration (including the bundled `zedcore.aar`) cannot be reused on iOS. A compatible iOS engine and its licensing/build integration must be selected and implemented separately.

A working packet-tunnel VPN also requires Apple's Network Extension entitlement and valid provisioning. A free Apple ID does not guarantee that entitlement.

## Build
Open `ZedSecure-iOS.xcodeproj` in Xcode on macOS, configure the app and packet-tunnel targets with matching bundle identifiers and signing, then build for a physical iPhone. The project file and signing configuration still need to be completed in Xcode.
