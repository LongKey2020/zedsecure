import XCTest
@testable import ZedSecureCore

final class ConfigurationParserTests: XCTestCase {
    func testParsesVLESSAuthorityAndCredentials() throws {
        let config = try ConfigurationParser.parseAuthority(
            from: "vless://user:pass@example.com:443?security=tls#Primary"
        )

        XCTAssertEqual(config.protocolType, .vless)
        XCTAssertEqual(config.host, "example.com")
        XCTAssertEqual(config.port, 443)
        XCTAssertEqual(config.username, "user")
        XCTAssertEqual(config.password, "pass")
        XCTAssertEqual(config.name, "Primary")
    }

    func testParsesIPv6Host() throws {
        let config = try ConfigurationParser.parseAuthority(
            from: "trojan://secret@[2001:db8::1]:8443#IPv6"
        )

        XCTAssertEqual(config.host, "2001:db8::1")
        XCTAssertEqual(config.port, 8443)
        XCTAssertEqual(config.password, "secret")
    }

    func testMapsProtocolAliases() throws {
        let config = try ConfigurationParser.parseAuthority(
            from: "wg://peer@example.org:51820"
        )

        XCTAssertEqual(config.protocolType, .wireGuard)
        XCTAssertEqual(config.port, 51820)
    }

    func testRejectsUnsupportedScheme() {
        XCTAssertThrowsError(
            try ConfigurationParser.parseAuthority(from: "ftp://example.com:21")
        ) { error in
            XCTAssertEqual(error as? ConfigurationParserError, .unsupportedScheme("ftp"))
        }
    }

    func testRejectsEncodedVmessUntilDedicatedDecoderExists() {
        XCTAssertThrowsError(
            try ConfigurationParser.parseAuthority(from: "vmess://eyJhZGQiOiJleGFtcGxlLmNvbSJ9")
        ) { error in
            XCTAssertEqual(error as? ConfigurationParserError, .encodedProfileNotSupported)
        }
    }
}
