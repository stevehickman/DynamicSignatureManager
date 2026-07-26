import SwiftUI

struct MenuBarView: View {

    @EnvironmentObject private var model: AppModel
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dynamic Signature")
                .font(.headline)

            currentQuoteSection

            statusSection

            Divider()

            Button("New Quote Now") {
                model.rotateNow()
            }

            Button("Copy Signature") {
                model.copyCurrentSignature()
            }

            Divider()

            Button("Quote Library…") {
                openWindow(id: WindowID.quoteLibrary)
                NSApp.activate(ignoringOtherApps: true)
            }

            Button("Settings…") {
                openSettings()
                NSApp.activate(ignoringOtherApps: true)
            }

            Divider()

            Button("Quit Dynamic Signature Manager") {
                NSApp.terminate(nil)
            }
        }
        .buttonStyle(.plain)
        .padding(12)
        .frame(width: 280)
    }

    @ViewBuilder
    private var currentQuoteSection: some View {
        if let quote = model.currentQuote {
            VStack(alignment: .leading, spacing: 2) {
                Text("\u{201C}\(quote.text)\u{201D}")
                    .font(.callout)
                    .lineLimit(4)
                if let author = quote.author {
                    Text("— \(author)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            Text("No quote selected yet.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var statusSection: some View {
        if let message = model.statusMessage {
            Label(message, systemImage: "exclamationmark.triangle")
                .font(.caption)
                .foregroundStyle(.orange)
        } else if model.hasPendingSync {
            Label("Waiting for Mail to open…", systemImage: "clock")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else if let synced = model.lastSyncDate {
            Label(
                "Synced \(synced.formatted(.relative(presentation: .named)))",
                systemImage: "checkmark.circle"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}
