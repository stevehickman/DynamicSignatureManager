import SwiftUI
import DynamicSignatureDomain

struct ProfilesView: View {

    @EnvironmentObject private var model: MobileAppModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(model.profiles) { profile in
                        NavigationLink(value: profile.id) {
                            HStack {
                                Text(profile.displayLabel)
                                Spacer()
                                if !profile.isEnabled {
                                    Image(systemName: "pause.circle")
                                        .foregroundStyle(.secondary)
                                } else if !profile.isConfigured {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                    .onDelete { offsets in
                        for profile in offsets.map({ model.profiles[$0] }) {
                            model.deleteProfile(id: profile.id)
                        }
                    }
                } footer: {
                    Text("One profile per identity — work, personal, and so on. Each renders its own signature from the shared quote.")
                }
            }
            .navigationTitle("Profiles")
            .navigationDestination(for: UUID.self) { id in
                if let profile = model.profiles.first(where: { $0.id == id }) {
                    ProfileEditorView(profile: profile)
                }
            }
            .toolbar {
                Button {
                    model.saveProfile(
                        SignatureProfile(
                            name: "New Profile",
                            signatureName: model.uniqueSignatureName()
                        )
                    )
                } label: {
                    Label("Add Profile", systemImage: "plus")
                }
            }
        }
    }
}

private struct ProfileEditorView: View {

    @EnvironmentObject private var model: MobileAppModel
    @Environment(\.dismiss) private var dismiss

    private let profileID: UUID

    @State private var name: String
    @State private var isEnabled: Bool
    @State private var displayName: String
    @State private var title: String
    @State private var organization: String
    @State private var email: String
    @State private var phone: String
    @State private var website: String
    @State private var signatureName: String
    @State private var includeQuote: Bool
    @State private var includeContactDetails: Bool

    init(profile: SignatureProfile) {
        self.profileID = profile.id
        _name = State(initialValue: profile.name)
        _isEnabled = State(initialValue: profile.isEnabled)
        _displayName = State(initialValue: profile.identity.displayName)
        _title = State(initialValue: profile.identity.title ?? "")
        _organization = State(initialValue: profile.identity.organization ?? "")
        _email = State(initialValue: profile.identity.email ?? "")
        _phone = State(initialValue: profile.identity.phone ?? "")
        _website = State(initialValue: profile.identity.website ?? "")
        _signatureName = State(initialValue: profile.signatureName)
        _includeQuote = State(initialValue: profile.template.includeQuote)
        _includeContactDetails = State(initialValue: profile.template.includeContactDetails)
    }

    var body: some View {
        Form {
            Section {
                TextField("Profile label", text: $name)
                Toggle("Enabled", isOn: $isEnabled)
            }

            Section("Identity") {
                TextField("Name", text: $displayName)
                TextField("Title", text: $title)
                TextField("Organization", text: $organization)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                TextField("Website", text: $website)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
            }

            Section {
                TextField("Signature name", text: $signatureName)
            } footer: {
                if signatureNameCollides {
                    Text("Another profile already uses this signature name.")
                        .foregroundStyle(.orange)
                } else {
                    Text("Identifies this profile's signature. On a Mac running Dynamic Signature Manager, it is the Apple Mail signature the profile owns.")
                }
            }

            Section {
                Toggle("Include a quote in the signature", isOn: $includeQuote)
                Toggle("Include contact details", isOn: $includeContactDetails)
            }
        }
        .navigationTitle(name.isEmpty ? "Profile" : name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    model.saveProfile(editedProfile)
                    dismiss()
                }
                .disabled(
                    displayName.trimmingCharacters(in: .whitespaces).isEmpty
                        || signatureName.trimmingCharacters(in: .whitespaces).isEmpty
                        || signatureNameCollides
                )
            }
        }
    }

    private var signatureNameCollides: Bool {
        let trimmed = signatureName.trimmingCharacters(in: .whitespaces).lowercased()
        return model.profiles.contains {
            $0.id != profileID
                && $0.signatureName.trimmingCharacters(in: .whitespaces).lowercased() == trimmed
        }
    }

    private var editedProfile: SignatureProfile {
        SignatureProfile(
            id: profileID,
            name: name,
            identity: Identity(
                displayName: displayName,
                title: optional(title),
                organization: optional(organization),
                email: optional(email),
                phone: optional(phone),
                website: optional(website)
            ),
            signatureName: signatureName.trimmingCharacters(in: .whitespaces),
            template: SignatureTemplate(
                includeIdentity: true,
                includeContactDetails: includeContactDetails,
                includeQuote: includeQuote
            ),
            isEnabled: isEnabled
        )
    }

    private func optional(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }
}
