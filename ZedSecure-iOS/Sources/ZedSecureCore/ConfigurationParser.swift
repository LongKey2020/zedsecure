import Foundation

public enum ConfigurationParserError: Error, Equatable {
    case malformedURI
    case unsupportedScheme(String?)
    case missingHost
    case invalidPort
    case encodedProfileNotSupported
}

public enum ConfigurationParser {
    /// Parses the URI authority for common endpoint-based profiles.
    /// This is a foundation parser, not a complete protocol decoder: VMess
    /// and some Shadowsocks links use encoded payload formats and need
    /// dedicated decoders before they can be imported.
    public static func parseAuthority(from text: String) throws -> ServerConfiguration {
        guard let components = URLComponents(string: text),
              let scheme = components.scheme?.lowercased() else {
            throw ConfigurationParserError.malformedURI
        }

        guard let protocolType = ServerProtocol(uriScheme: scheme) else {
            throw ConfigurationParserError.unsupportedScheme(scheme)
        }

        if scheme == "vmess" || scheme == "ss" {
            throw ConfigurationParserError.encodedProfileNotSupported
        }

        guard let host = components.host, !host.isEmpty else {
            throw ConfigurationParserError.missingHost
        }

        if let port = components.port, !(1...65535).contains(port) {
            throw ConfigurationParserError.invalidPort
        }

        let user = components.user?.removingPercentEncoding
        let password = components.password?.removingPercentEncoding
        let displayName = components.fragment?.removingPercentEncoding
            .flatMap { $0.isEmpty ? nil : $0 } ?? host

        return ServerConfiguration(
            name: displayName,
            protocolType: protocolType,
            host: host,
            port: components.port,
            username: user,
            password: password,
            rawURI: text
        )
    }
}
