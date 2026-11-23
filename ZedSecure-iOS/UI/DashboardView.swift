import SwiftUI

struct DashboardView: View {
    @State private var isConnected = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 64))
                    .foregroundStyle(isConnected ? .green : .cyan)

                Text("ZedSecure")
                    .font(.largeTitle.bold())

                Text(isConnected ? "Connected" : "Not Connected")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Button {
                    // Connection is intentionally not wired until the iOS
                    // packet-tunnel engine and entitlements are configured.
                } label: {
                    Text(isConnected ? "Disconnect" : "Connect")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cyan.opacity(0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(true)

                Text("VPN engine integration is not configured yet.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("Dashboard")
        }
    }
}
