import SwiftUI

struct DadDashboardView: View {
    @StateObject private var airtable = AirtableService.shared
    @State private var selectedTab = 0
    @State private var showingSettings = false

    var body: some View {
        ZStack {
            Color.mcBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView

                // Tab Content
                TabView(selection: $selectedTab) {
                    // Command Center
                    DadCommandCenterView()
                        .tag(0)

                    // Claude Chat
                    DadChatView()
                        .tag(1)

                    // Database Manager
                    DadDatabaseView()
                        .tag(2)

                    // Kids Preview
                    KidsDashboardView()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Tab Bar
                dadTabBar
            }
        }
        .preferredColorScheme(.dark)
        .task {
            await airtable.loadAllData()
        }
        .sheet(isPresented: $showingSettings) {
            DadSettingsView()
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("COMMAND CENTER")
                    .font(.headline)
                    .foregroundColor(.mcGold)
                Text("Team Streem Realm")
                    .font(.caption)
                    .foregroundColor(.mcStone)
            }

            Spacer()

            // Settings button
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.mcStone)
            }

            // Refresh button
            if airtable.isLoading {
                ProgressView()
                    .tint(.mcDiamond)
                    .padding(.leading, 12)
            } else {
                Button {
                    Task {
                        HapticManager.shared.refresh()
                        await airtable.loadAllData()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.mcDiamond)
                }
                .padding(.leading, 12)
            }
        }
        .padding()
        .background(Color.mcBedrock)
    }

    // MARK: - Tab Bar
    private var dadTabBar: some View {
        HStack(spacing: 0) {
            DadTabButton(icon: "gamecontroller.fill", label: "Control", isSelected: selectedTab == 0) {
                selectedTab = 0
            }

            DadTabButton(icon: "bubble.left.and.bubble.right.fill", label: "Claude", isSelected: selectedTab == 1) {
                selectedTab = 1
            }

            DadTabButton(icon: "cylinder.split.1x2.fill", label: "Database", isSelected: selectedTab == 2) {
                selectedTab = 2
            }

            DadTabButton(icon: "eye.fill", label: "Kids View", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
        }
        .padding(.vertical, 8)
        .background(Color.mcBedrock)
    }
}

// MARK: - Dad Tab Button
struct DadTabButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .mcGold : .mcStone)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview
#Preview {
    DadDashboardView()
}
