import Foundation

public enum ConfigurationParserError: Error, Equatable {
    case malformedURI
    case unsupportedScheme(String?)
    case missingHost
    case invalidPort
    case invalidBase64Payload
    case invalidEncodedProfile
}

public enum ConfigurationParser {
    /// Parses common share links into a normalized endpoint model.
    /// Transport/TLS/REALITY query parameters are retained in rawURI but are
    /// not yet translated into engine-specific configuration objects.
    public static func parse(from text: String) throws -> ServerConfiguration {
        guard let scheme = URLComponents(string: text)?.scheme?.lowercased() else {
            throw ConfigurationParserError.malformedURI
        }
        guard let type = ServerProtocol(uriScheme: scheme) else {
            throw ConfigurationParserError.unsupportedScheme(scheme)
        }
        switch type {
        case .vmess: return try parseVmess(text)
        case .shadowsocks: return try parseShadowsocks(text)
        default: return try parseAuthority(text, protocolType: type)
        }
    }

    public static func parseAuthority(from text: String) throws -> ServerConfiguration {
        try parse(from: text)
    }

    private static func parseAuthority(_ text: String, protocolType: ServerProtocol) throws -> ServerConfiguration {
        guard let c = URLComponents(string: text), c.scheme != nil else {
            throw ConfigurationParserError.malformedURI
        }
        guard let rawHost = c.host, !rawHost.isEmpty else { throw ConfigurationParserError.missingHost }
        let host = rawHost.hasPrefix("[") && rawHost.hasSuffix("]") ? String(rawHost.dropFirst().dropLast()) : rawHost
        if let port = c.port, !(1...65535).contains(port) { throw ConfigurationParserError.invalidPort }
        let name = c.fragment?.removingPercentEncoding.flatMap { $0.isEmpty ? nil : $0 } ?? host
        return ServerConfiguration(name: name, protocolType: protocolType, host: host,
            port: c.port, username: protocolType == .trojan ? nil : c.user?.removingPercentEncoding,
            password: (c.password ?? (protocolType == .trojan ? c.user : nil))?.removingPercentEncoding,
            rawURI: text)
    }

    private static func parseVmess(_ text: String) throws -> ServerConfiguration {
        let payload = String(text.dropFirst("vmess://".count))
        guard let data = decodeBase64(payload),
              let object = try? JSONSerialization.jsonObject(with: data),
              let json = object as? [String: Any],
              let host = json["add"] as? String, !host.isEmpty,
              let uuid = json["id"] as? String, !uuid.isEmpty else {
            throw ConfigurationParserError.invalidEncodedProfile
        }
        let port = integer(json["port"])
        if let port, !(1...65535).contains(port) { throw ConfigurationParserError.invalidPort }
        let name = (json["ps"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? host
        return ServerConfiguration(name: name, protocolType: .vmess, host: host,
            port: port, username: uuid, rawURI: text)
    }

    private static func parseShadowsocks(_ text: String) throws -> ServerConfiguration {
        let payload = String(text.dropFirst("ss://".count))
            .split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? ""
        let cleanPayload = payload.split(separator: "?", maxSplits: 1).first.map(String.init) ?? ""
        let pieces = cleanPayload.split(separator: "@", maxSplits: 1, omittingEmptySubsequences: false)
        let credentialsText: String
        let endpointText: String

        if pieces.count == 2 {
            credentialsText = String(pieces[0])
            endpointText = String(pieces[1])
        } else {
            guard let decoded = decodeBase64(cleanPayload),
                  let decodedText = String(data: decoded, encoding: .utf8) else {
                throw ConfigurationParserError.invalidBase64Payload
            }
            let decodedParts = decodedText.split(separator: "@", maxSplits: 1, omittingEmptySubsequences: false)
            guard decodedParts.count == 2 else { throw ConfigurationParserError.invalidEncodedProfile }
            credentialsText = String(decodedParts[0])
            endpointText = String(decodedParts[1])
        }

        guard let endpoint = URLComponents(string: "ss://x@" + endpointText),
              let rawHost = endpoint.host, !rawHost.isEmpty else {
            throw ConfigurationParserError.missingHost
        }
        let host = rawHost.hasPrefix("[") && rawHost.hasSuffix("]") ? String(rawHost.dropFirst().dropLast()) : rawHost
        let port = endpoint.port
        if let port, !(1...65535).contains(port) { throw ConfigurationParserError.invalidPort }

        let decodedCredentials: String
        if let decoded = decodeBase64(credentialsText),
           let value = String(data: decoded, encoding: .utf8), value.contains(":") {
            decodedCredentials = value
        } else {
            decodedCredentials = credentialsText.removingPercentEncoding ?? credentialsText
        }
        let pair = decodedCredentials.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
        guard pair.count == 2 else { throw ConfigurationParserError.invalidEncodedProfile }
        let label = text.split(separator: "#", maxSplits: 1).dropFirst().first.map(String.init)?.removingPercentEncoding
        let name = label.flatMap { $0.isEmpty ? nil : $0 } ?? host
        return ServerConfiguration(name: name, protocolType: .shadowsocks, host: host,
            port: port, username: String(pair[0]), password: String(pair[1]), rawURI: text)
    }

    private static func decodeBase64(_ value: String) -> Data? {
        var normalized = value.replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        normalized = normalized.replacingOccurrences(of: " ", with: "+")
        let remainder = normalized.count % 4
        if remainder != 0 { normalized += String(repeating: "=", count: 4 - remainder) }
        return Data(base64Encoded: normalized)
    }

    private static func integer(_ value: Any?) -> Int? {
        if let number = value as? NSNumber { return number.intValue }
        if let string = value as? String { return Int(string) }
        return nil
    }
}
