import Foundation

struct ServerConfiguration: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var address: String
    var port: Int
    var rawURI: String
}
