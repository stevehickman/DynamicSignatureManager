import ServiceManagement
import SwiftUI
import DynamicSignatureDomain

struct SettingsView: View {

    var body: some View {
        TabView {
            ProfilesSettingsView()
                .tabItem { Label("Profiles", systemImage: "person.2") }

            RotationSettingsView()
                .tabItem { Label("Rotation", systemImage: "arrow.triangle.2.circlepath") }

            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }
        }
        .frame(width: 640)
    }
}

// MARK: - Profiles

private struct ProfilesSettingsView: View {

    @EnvironmentObject private var model: AppModel

    @State private var selectedProfileID: UUID?

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            profileList
                .frame(width: 180)

            Divider()

            if let profile = selectedProfile {
                ProfileEditorView(profile: profile) { updated in
                    model.saveProfile(updated)
                } onDelete: {
                    model.deleteProfile(id: profile.id)
                    selectedProfileID = model.profiles.first?.id
                }
                .id(profile.id)
            } else {
                VStack {
                    Text("Add a profile for each mail account you want a signature for.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(height: 400)
        .onAppear {
            if selectedProfileID == nil {
                selectedProfileID = model.profiles.first?.id
            }
        }
    }

    private var selectedProfile: SignatureProfile? {
        model.profiles.first { $0.id == selectedProfileID }
    }

    private var profileList: some View {
        VStack(spacing: 0) {
            List(selection: $selectedProfileID) {
                ForEach(model.profiles) { profile in
                    HStack {
                        Text(profile.displayLabel)
                        Spacer()
                        if !profile.isEnabled {
                            Image(systemName: "pause.circle")
                                .foregroundStyle(.secondary)
                                .help("Disabled")
                        } else if !profile.isConfigured {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(.orange)
                                .help("Needs a name before it can sync")
                        }
                    }
                    .tag(profile.id)
                }
            }
            .listStyle(.sidebar)

            Divider()

            HStack(spacing: 8) {
                Button {
                    addProfile()
                } label: {
                    Image(systemName: "plus")
                }
                .help("Add a profile")

                Button {
                    if let id = selectedProfileID {
                        model.deleteProfile(id: id)
                        selectedProfileID = model.profiles.first?.id
                    }
                } label: {
                    Image(systemName: "minus")
                }
                .disabled(selectedProfileID == nil)
                .help("Remove the selected profile")

                Spacer()
            }
            .buttonStyle(.borderless)
            .padding(6)
        }
    }

    private func addProfile() {
        let profile = SignatureProfile(
            name: "New Profile",
            signatureName: uniqueSignatureName()
        )
        model.saveProfile(profile)
        selectedProfileID = profile.id
    }

    /// Proposes a Mail signature name not already used by another profile.
    private func uniqueSignatureName() -> String {
        let existing = Set(model.profiles.map { $0.signatureName.lowercased() })
        if !existing.contains("dynamic quote") { return "Dynamic Quote" }
        var index = 2
        while existing.contains("dynamic quote \(index)") { index += 1 }
        return "Dynamic Quote \(index)"
    }
}

private struct ProfileEditorView: View {

    @EnvironmentObject private var model: AppModel

    let onSave: (SignatureProfile) -> Void
    let onDelete: () -> Void

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

    init(
        profile: SignatureProfile,
        onSave: @escaping (SignatureProfile) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.onSave = onSave
        self.onDelete = onDelete
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
            TextField("Profile label", text: $name)
            Toggle("Enabled", isOn: $isEnabled)

            Divider()

            TextField("Name", text: $displayName)
            TextField("Title", text: $title)
            TextField("Organization", text: $organization)
            TextField("Email", text: $email)
            TextField("Phone", text: $phone)
            TextField("Website", text: $website)

            Divider()

            TextField("Mail signature name", text: $signatureName)
            if signatureNameCollides {
                Text("Another profile already uses this Mail signature name.")
                    .font(.caption)
                    .foregroundStyle(.orange)
            } else {
                Text("The app maintains a Mail signature with this name for this profile. In Mail → Settings → Signatures, assign it to the matching account.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Toggle("Include a quote in the signature", isOn: $includeQuote)
            Toggle("Include contact details", isOn: $includeContactDetails)

            HStack {
                Button("Delete Profile", role: .destructive) {
                    onDelete()
                }
                Spacer()
                Button("Save") {
                    onSave(editedProfile)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(
                    displayName.trimmingCharacters(in: .whitespaces).isEmpty
                        || signatureName.trimmingCharacters(in: .whitespaces).isEmpty
                        || signatureNameCollides
                )
            }
        }
        .padding(20)
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

// MARK: - Rotation

private struct RotationSettingsView: View {

    @EnvironmentObject private var model: AppModel

    @AppStorage(AppModel.DefaultsKey.rotationEnabled) private var rotationEnabled = true
    @AppStorage(AppModel.DefaultsKey.rotationInterval) private var rotationInterval = RotationInterval.daily.rawValue
    @AppStorage(AppModel.DefaultsKey.recentQuoteLimit) private var recentQuoteLimit = 10

    var body: some View {
        Form {
            Toggle("Rotate quote automatically", isOn: $rotationEnabled)

            Picker("Rotation interval", selection: $rotationInterval) {
                ForEach(RotationInterval.allCases, id: \.rawValue) { interval in
                    Text(interval.displayName).tag(interval.rawValue)
                }
            }
            .disabled(!rotationEnabled)

            Stepper(
                "Avoid repeating the last \(recentQuoteLimit) quotes",
                value: $recentQuoteLimit,
                in: 0...50
            )

            Divider()

            Text("Rotation updates the Mail signature of every enabled profile. Per-profile options (quote, contact details, signature name) live in the Profiles tab.")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Button("Sync to Mail Now") {
                    model.resyncToMail()
                }
            }
        }
        .padding(20)
    }
}

// MARK: - General

private struct GeneralSettingsView: View {

    @EnvironmentObject private var model: AppModel

    @State private var launchAtLogin = false
    @State private var loginItemError: String?

    /// SMAppService only works from a real .app bundle, not a bare
    /// `swift run` executable.
    private var isBundledApp: Bool {
        Bundle.main.bundleURL.pathExtension == "app"
    }

    var body: some View {
        Form {
            Toggle("Launch at login", isOn: $launchAtLogin)
                .disabled(!isBundledApp)
                .onChange(of: launchAtLogin) { _, newValue in
                    setLaunchAtLogin(newValue)
                }

            if !isBundledApp {
                Text("Launch at login requires running the packaged app (Scripts/package-app.sh).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let loginItemError {
                Text(loginItemError)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            Divider()

            LabeledContent("Data folder") {
                Button("Show in Finder") {
                    model.revealDataFolder()
                }
            }
            Text("Quotes, profiles, and rotation state are stored as editable JSON files.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        guard isBundledApp else { return }
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            loginItemError = nil
        } catch {
            loginItemError = error.localizedDescription
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}
