import ServiceManagement
import SwiftUI
import DynamicSignatureDomain

struct SettingsView: View {

    var body: some View {
        TabView {
            IdentitySettingsView()
                .tabItem { Label("Identity", systemImage: "person") }

            RotationSettingsView()
                .tabItem { Label("Rotation", systemImage: "arrow.triangle.2.circlepath") }

            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }
        }
        .frame(width: 460)
    }
}

private struct IdentitySettingsView: View {

    @EnvironmentObject private var model: AppModel

    @State private var displayName = ""
    @State private var title = ""
    @State private var organization = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var website = ""
    @State private var loaded = false

    var body: some View {
        Form {
            TextField("Name", text: $displayName)
            TextField("Title", text: $title)
            TextField("Organization", text: $organization)
            TextField("Email", text: $email)
            TextField("Phone", text: $phone)
            TextField("Website", text: $website)

            HStack {
                Spacer()
                Button("Save") {
                    model.saveIdentity(Identity(
                        displayName: displayName,
                        title: optional(title),
                        organization: optional(organization),
                        email: optional(email),
                        phone: optional(phone),
                        website: optional(website)
                    ))
                }
                .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .onAppear {
            guard !loaded else { return }
            loaded = true
            let identity = model.identity
            displayName = identity.displayName
            title = identity.title ?? ""
            organization = identity.organization ?? ""
            email = identity.email ?? ""
            phone = identity.phone ?? ""
            website = identity.website ?? ""
        }
    }

    private func optional(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }
}

private struct RotationSettingsView: View {

    @EnvironmentObject private var model: AppModel

    @AppStorage(AppModel.DefaultsKey.rotationEnabled) private var rotationEnabled = true
    @AppStorage(AppModel.DefaultsKey.rotationInterval) private var rotationInterval = RotationInterval.daily.rawValue
    @AppStorage(AppModel.DefaultsKey.signatureName) private var signatureName = "Dynamic Quote"
    @AppStorage(AppModel.DefaultsKey.recentQuoteLimit) private var recentQuoteLimit = 10
    @AppStorage(AppModel.DefaultsKey.includeQuote) private var includeQuote = true
    @AppStorage(AppModel.DefaultsKey.includeContactDetails) private var includeContactDetails = true

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

            Toggle("Include a quote in the signature", isOn: $includeQuote)
            Toggle("Include contact details", isOn: $includeContactDetails)

            Divider()

            TextField("Mail signature name", text: $signatureName)
            Text("The app creates and maintains a signature with this name in Apple Mail. Select it for your account in Mail → Settings → Signatures.")
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
            Text("Quotes, identity, and rotation state are stored as editable JSON files.")
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
