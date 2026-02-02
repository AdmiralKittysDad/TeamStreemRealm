import SwiftUI

struct DadChatView: View {
    @StateObject private var claude = ClaudeService.shared
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            chatHeader

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Welcome message if empty
                        if claude.messages.isEmpty {
                            welcomeMessage
                        }

                        // Chat messages
                        ForEach(claude.messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }

                        // Loading indicator
                        if claude.isProcessing {
                            HStack {
                                ProgressView()
                                    .tint(.mcDiamond)
                                Text("Claude is thinking...")
                                    .font(.caption)
                                    .foregroundColor(.mcStone)
                            }
                            .padding()
                            .id("loading")
                        }
                    }
                    .padding()
                }
                .onChange(of: claude.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(claude.messages.last?.id ?? "loading", anchor: .bottom)
                    }
                }
            }

            // Error display
            if let error = claude.lastError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.mcRedstone)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.mcRedstone)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.mcRedstone.opacity(0.1))
            }

            // Input area
            inputArea
        }
        .background(Color.mcBackground)
    }

    // MARK: - Header
    private var chatHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("🤖 CLAUDE ASSISTANT")
                    .font(.headline)
                    .foregroundColor(.mcDiamond)
                Text("Ask me to log sessions, update zones, get stats...")
                    .font(.caption)
                    .foregroundColor(.mcStone)
            }

            Spacer()

            // Clear chat button
            if !claude.messages.isEmpty {
                Button {
                    claude.clearHistory()
                    HapticManager.shared.impact(.light)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.mcStone)
                }
            }
        }
        .padding()
        .background(Color.mcCardBg)
    }

    // MARK: - Welcome Message
    private var welcomeMessage: some View {
        VStack(spacing: 16) {
            Text("🏰")
                .font(.system(size: 60))

            Text("Welcome, Master Builder!")
                .font(.title2.bold())
                .foregroundColor(.mcGold)

            Text("I'm your build assistant. I can help you:")
                .font(.subheadline)
                .foregroundColor(.mcStone)

            VStack(alignment: .leading, spacing: 8) {
                featureRow(icon: "📝", text: "Log build sessions")
                featureRow(icon: "🗺️", text: "Update zone status & visibility")
                featureRow(icon: "📊", text: "Check project stats")
                featureRow(icon: "🔮", text: "Set mystery teasers for kids")
            }

            Text("Just type naturally - I understand context!")
                .font(.caption)
                .foregroundColor(.mcAmethyst)
                .italic()
        }
        .padding(24)
        .background(Color.mcCardBg)
        .cornerRadius(12)
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack {
            Text(icon)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }

    // MARK: - Input Area
    private var inputArea: some View {
        HStack(spacing: 12) {
            // Quick actions
            Menu {
                Button("📝 Log a session") {
                    inputText = "I want to log a build session"
                    sendMessage()
                }
                Button("📊 Get stats") {
                    inputText = "What are my current stats?"
                    sendMessage()
                }
                Button("🗺️ Zone status") {
                    inputText = "Show me zone status"
                    sendMessage()
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.mcDiamond)
            }

            // Text input
            TextField("Message Claude...", text: $inputText)
                .textFieldStyle(.roundedBorder)
                .focused($isInputFocused)
                .submitLabel(.send)
                .onSubmit {
                    sendMessage()
                }

            // Send button
            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundColor(inputText.isEmpty ? .mcStone : .mcEmerald)
            }
            .disabled(inputText.isEmpty || claude.isProcessing)
        }
        .padding()
        .background(Color.mcBedrock)
    }

    private func sendMessage() {
        guard !inputText.isEmpty else { return }

        let message = inputText
        inputText = ""
        isInputFocused = false

        HapticManager.shared.impact(.light)

        Task {
            await claude.sendMessage(message)
        }
    }
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ClaudeMessage

    var isUser: Bool {
        message.role == .user
    }

    var body: some View {
        HStack {
            if isUser { Spacer() }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                // Message content
                Text(parseMarkdown(message.content))
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(isUser ? Color.mcDiamond.opacity(0.8) : Color.mcCardBg)
                    .cornerRadius(16)
                    .cornerRadius(16, corners: isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])

                // Timestamp
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.mcStone)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isUser ? .trailing : .leading)

            if !isUser { Spacer() }
        }
    }

    private func parseMarkdown(_ text: String) -> AttributedString {
        // Simple markdown parsing
        var result = text
        // Bold
        result = result.replacingOccurrences(of: "\\*\\*(.+?)\\*\\*", with: "$1", options: .regularExpression)

        if let attributed = try? AttributedString(markdown: text) {
            return attributed
        }
        return AttributedString(text)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#Preview {
    DadChatView()
}
