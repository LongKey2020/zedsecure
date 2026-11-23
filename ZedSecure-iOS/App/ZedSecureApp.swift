import SwiftUI

@main
struct ZedSecureApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .preferredColorScheme(.dark)
        }
    }
}
