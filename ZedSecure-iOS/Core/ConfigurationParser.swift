import Foundation

enum ConfigurationParserError: Error {
    case unsupportedScheme
    case invalidHost
    case invalidPort
}

enum ConfigurationParser {
    /// Parses the common authority portion of a supported server URI.
    /// Protocol-specific credentials and transport options still require
    /// dedicated parsers before a profile can be used by a VPN engine.
    static func parseAuthority(from text: String) throws -> (scheme: String, host: String, port: Int?) {
        guard let components = URLComponents(string: text),
              let scheme = components.scheme?.lowercased() else {
            throw ConfigurationParserError.unsupportedScheme
        }

        let supported = ["vless", "vmess", "trojan", "ss", "socks", "http", "https"]
        guard supported.contains(scheme) else {
            throw ConfigurationParserError.unsupportedScheme
        }
        guard let host = components.host, !host.isEmpty else {
            throw ConfigurationParserError.invalidHost
        }
        if let port = components.port, !(1...65535).contains(port) {
            throw ConfigurationParserError.invalidPort
        }
        return (scheme, host, components.port)
    }
}
