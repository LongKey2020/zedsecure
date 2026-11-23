import Foundation

public enum ServerProtocol: String, Codable, CaseIterable, Sendable {
    case vless
    case vmess
    case trojan
    case shadowsocks
    case socks
    case http
    case https
    case wireGuard
    case amneziaWG
    case hysteria
    case hysteria2
    case masque

    public init?(uriScheme: String) {
        switch uriScheme.lowercased() {
        case "vless": self = .vless
        case "vmess": self = .vmess
        case "trojan": self = .trojan
        case "ss", "shadowsocks": self = .shadowsocks
        case "socks", "socks5", "socks4", "socks4a": self = .socks
        case "http": self = .http
        case "https": self = .https
        case "wireguard", "wg": self = .wireGuard
        case "awg", "amneziawg": self = .amneziaWG
        case "hysteria": self = .hysteria
        case "hysteria2", "hy2": self = .hysteria2
        case "masque": self = .masque
        default: return nil
        }
    }
}

public struct ServerConfiguration: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var protocolType: ServerProtocol
    public var host: String
    public var port: Int?
    public var username: String?
    public var password: String?
    public var rawURI: String

    public init(
        id: UUID = UUID(),
        name: String,
        protocolType: ServerProtocol,
        host: String,
        port: Int?,
        username: String? = nil,
        password: String? = nil,
        rawURI: String
    ) {
        self.id = id
        self.name = name
        self.protocolType = protocolType
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.rawURI = rawURI
    }
}
