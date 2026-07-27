import SwiftUI
import DynamicSignatureDomain
import DynamicSignatureApplication

/// Home tab: the current quote, a rendered signature per active profile, and
/// copy buttons for pasting into Settings → Mail → Signature.
struct SignatureView: View {

    @EnvironmentObject private var model: MobileAppModel
    @State private var copiedProfileID: UUID?

    var body: some View {
        NavigationStack {
            List {
                if model.activeProfiles.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "No profile set up",
                            systemImage: "person.crop.circle.badge.exclamationmark",
                            description: Text("In the Profiles tab, enter at least your name in a profile to start generating signatures.")
                        )
                    }
                } else {
                    quoteSection
                    signatureSections
                }

                if let message = model.statusMessage {
                    Section {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Signature")
        }
    }

    private var quoteSection: some View {
        Section("Current quote") {
            if let quote = model.currentQuote {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quote.text)
                    if let author = quote.author, !author.isEmpty {
                        Text("— \(author)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("No quote selected yet.")
                    .foregroundStyle(.secondary)
            }

            Button {
                model.rotateNow()
            } label: {
                Label("New Quote Now", systemImage: "arrow.triangle.2.circlepath")
            }

            if let date = model.lastRotationDate {
                LabeledContent("Last rotated") {
                    Text(date, format: .dateTime.day().month().hour().minute())
                }
                .font(.caption)
            }
        }
    }

    @ViewBuilder
    private var signatureSections: some View {
        ForEach(model.currentSignatures, id: \.profileID) { signature in
            Section {
                Text(signature.text)
                    .font(.callout)
                    .textSelection(.enabled)

                Button {
                    if model.copySignature(profileID: signature.profileID) {
                        showCopiedFeedback(for: signature.profileID)
                    }
                } label: {
                    Label(
                        copiedProfileID == signature.profileID ? "Copied" : "Copy Signature",
                        systemImage: copiedProfileID == signature.profileID
                            ? "checkmark" : "doc.on.doc"
                    )
                }
            } header: {
                Text(profileLabel(for: signature))
            } footer: {
                if signature.profileID == model.currentSignatures.last?.profileID {
                    Text("Paste into Settings → Mail → Signature to use it in the Mail app. iOS offers no way to update Mail's signature automatically.")
                }
            }
        }
    }

    private func profileLabel(for signature: GeneratedSignature) -> String {
        model.profiles.first { $0.id == signature.profileID }?.displayLabel
            ?? signature.signatureName
    }

    private func showCopiedFeedback(for id: UUID) {
        copiedProfileID = id
        Task {
            try? await Task.sleep(for: .seconds(2))
            if copiedProfileID == id {
                copiedProfileID = nil
            }
        }
    }
}
