import SwiftUI

struct DadSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var claude = ClaudeService.shared
    @AppStorage("appMode") private var appMode: AppMode = .dad

    @State private var claudeAPIKey = ""
    @State private var showingAPIKey = false
    @State private var secretCode = UserDefaults.standard.string(forKey: "dad_secret_code") ?? "1234"

    var body: some View {
        NavigationView {
            ZStack {
                Color.mcBackground.ignoresSafeArea()

                List {
                    // Switch to Kids Mode
                    Section {
                        Button {
                            HapticManager.shared.notification(.success)
                            appMode = .kids
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "figure.and.child.holdinghands")
                                    .font(.title2)
                                Text("Switch to Kids Mode")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.mcDiamond)
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color.mcOceanDeep)
                    } header: {
                        Text("App Mode")
                            .foregroundColor(.mcGold)
                    } footer: {
                        Text("To get back to Dad Mode, hold anywhere on the Kids screen for 3 seconds and enter the code.")
                            .foregroundColor(.mcStone)
                    }

                    // Secret Code Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("🔐 Secret Access Code")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }

                            HStack {
                                TextField("4-digit code", text: $secretCode)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                                    .onChange(of: secretCode) { newValue in
                                        // Limit to 4 digits
                                        if newValue.count > 4 {
                                            secretCode = String(newValue.prefix(4))
                                        }
                                        // Only allow numbers
                                        secretCode = newValue.filter { $0.isNumber }
                                    }

                                Button("Save") {
                                    UserDefaults.standard.set(secretCode, forKey: "dad_secret_code")
                                    HapticManager.shared.notification(.success)
                                }
                                .buttonStyle(MinecraftButtonStyle(color: .mcEmerald))
                                .disabled(secretCode.count != 4)
                            }

                            Text("This code is needed to access Dad Mode from the Kids app.")
                                .font(.caption)
                                .foregroundColor(.mcStone)
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(Color.mcCardBg)
                    } header: {
                        Text("Security")
                            .foregroundColor(.mcGold)
                    }

                    // Claude API Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("🤖 Claude API Key")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Spacer()

                                if claude.hasAPIKey {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.mcEmerald)
                                } else {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.mcRedstone)
                                }
                            }

                            HStack {
                                if showingAPIKey {
                                    TextField("sk-ant-...", text: $claudeAPIKey)
                                        .textFieldStyle(.roundedBorder)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                } else {
                                    SecureField("sk-ant-...", text: $claudeAPIKey)
                                        .textFieldStyle(.roundedBorder)
                                }

                                Button {
                                    showingAPIKey.toggle()
                                } label: {
                                    Image(systemName: showingAPIKey ? "eye.slash" : "eye")
                                        .foregroundColor(.mcStone)
                                }
                            }

                            Button("Save API Key") {
                                claude.setAPIKey(claudeAPIKey)
                                HapticManager.shared.notification(.success)
                            }
                            .buttonStyle(MinecraftButtonStyle(color: .mcEmerald))
                            .disabled(claudeAPIKey.isEmpty)

                            Text("Your API key is stored locally on this device.")
                                .font(.caption)
                                .foregroundColor(.mcStone)
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(Color.mcCardBg)
                    } header: {
                        Text("AI Assistant")
                            .foregroundColor(.mcGold)
                    }

                    // Airtable Section
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            infoRow("Base ID", value: AirtableConfig.baseId)
                            infoRow("Status", value: "Connected", color: .mcEmerald)
                        }
                        .listRowBackground(Color.mcCardBg)
                    } header: {
                        Text("Airtable Database")
                            .foregroundColor(.mcGold)
                    }

                    // App Info Section
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            infoRow("Version", value: "1.0.0")
                            infoRow("Build", value: "1")
                            infoRow("Platform", value: "iOS 15+")
                        }
                        .listRowBackground(Color.mcCardBg)
                    } header: {
                        Text("About")
                            .foregroundColor(.mcGold)
                    }

                    // Danger Zone
                    Section {
                        Button {
                            claude.clearHistory()
                            HapticManager.shared.notification(.warning)
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear Chat History")
                            }
                            .foregroundColor(.mcRedstone)
                        }
                        .listRowBackground(Color.mcCardBg)
                    } header: {
                        Text("Data Management")
                            .foregroundColor(.mcRedstone)
                    }
                }
                .listStyle(.insetGrouped)
                .modifier(HideListBackgroundModifier())
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.mcDiamond)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Load current key (masked)
            if claude.hasAPIKey {
                claudeAPIKey = "••••••••••••••••"
            }
        }
    }

    private func infoRow(_ label: String, value: String, color: Color = .white) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.mcStone)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(color)
        }
    }
}

// MARK: - Preview
#Preview {
    DadSettingsView()
}
