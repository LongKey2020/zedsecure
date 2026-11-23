import NetworkExtension

final class PacketTunnelProvider: NEPacketTunnelProvider {
    override func startTunnel(options: [String : NSObject]?,
                              completionHandler: @escaping (Error?) -> Void) {
        // TODO: Start a real iOS-compatible proxy/VPN engine and configure
        // NEPacketTunnelNetworkSettings before reporting success.
        completionHandler(NSError(
            domain: "ZedSecure",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey:
                "The iOS VPN engine has not been integrated."]
        ))
    }

    override func stopTunnel(with reason: NEProviderStopReason,
                             completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
