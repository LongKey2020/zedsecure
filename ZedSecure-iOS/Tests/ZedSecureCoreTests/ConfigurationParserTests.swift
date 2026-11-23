import XCTest
@testable import ZedSecureCore

final class ConfigurationParserTests: XCTestCase {
    func testParsesVLESSAuthorityAndCredentials() throws {
        let c = try ConfigurationParser.parse(from: "vless://user:pass@example.com:443?security=tls#Primary")
        XCTAssertEqual(c.protocolType, .vless); XCTAssertEqual(c.host, "example.com")
        XCTAssertEqual(c.port, 443); XCTAssertEqual(c.username, "user")
        XCTAssertEqual(c.password, "pass"); XCTAssertEqual(c.name, "Primary")
    }

    func testParsesIPv6Trojan() throws {
        let c = try ConfigurationParser.parse(from: "trojan://secret@[2001:db8::1]:8443#IPv6")
        XCTAssertEqual(c.host, "2001:db8::1"); XCTAssertEqual(c.port, 8443)
        XCTAssertEqual(c.password, "secret")
    }

    func testMapsWireGuardAlias() throws {
        let c = try ConfigurationParser.parse(from: "wg://peer@example.org:51820")
        XCTAssertEqual(c.protocolType, .wireGuard); XCTAssertEqual(c.port, 51820)
    }

    func testParsesVMessBase64JSON() throws {
        let json = #"{"v":"2","ps":"Office","add":"vm.example.net","port":"443","id":"123e4567-e89b-12d3-a456-426614174000","aid":"0","net":"ws"}"#
        let encoded = Data(json.utf8).base64EncodedString()
        let c = try ConfigurationParser.parse(from: "vmess://\(encoded)")
        XCTAssertEqual(c.protocolType, .vmess); XCTAssertEqual(c.host, "vm.example.net")
        XCTAssertEqual(c.port, 443); XCTAssertEqual(c.username, "123e4567-e89b-12d3-a456-426614174000")
        XCTAssertEqual(c.name, "Office")
    }

    func testParsesShadowsocksBase64Payload() throws {
        let encoded = Data("aes-128-gcm:secret@ss.example.net:8388".utf8).base64EncodedString()
        let c = try ConfigurationParser.parse(from: "ss://\(encoded)#Home")
        XCTAssertEqual(c.protocolType, .shadowsocks); XCTAssertEqual(c.host, "ss.example.net")
        XCTAssertEqual(c.port, 8388); XCTAssertEqual(c.username, "aes-128-gcm")
        XCTAssertEqual(c.password, "secret"); XCTAssertEqual(c.name, "Home")
    }

    func testRejectsUnsupportedScheme() {
        XCTAssertThrowsError(try ConfigurationParser.parse(from: "ftp://example.com:21")) {
            XCTAssertEqual($0 as? ConfigurationParserError, .unsupportedScheme("ftp"))
        }
    }

    func testRejectsMalformedVmessPayload() {
        XCTAssertThrowsError(try ConfigurationParser.parse(from: "vmess://not-valid-json")) {
            XCTAssertEqual($0 as? ConfigurationParserError, .invalidEncodedProfile)
        }
    }
}
