import SwiftUI
import DynamicSignatureDomain

struct SettingsView: View {

    @AppStorage(MobileAppModel.DefaultsKey.rotationEnabled) private var rotationEnabled = true
    @AppStorage(MobileAppModel.DefaultsKey.rotationInterval) private var rotationInterval = RotationInterval.daily.rawValue
    @AppStorage(MobileAppModel.DefaultsKey.recentQuoteLimit) private var recentQuoteLimit = 10
    @AppStorage(MobileAppModel.DefaultsKey.preferSeasonalQuotes) private var preferSeasonalQuotes = true
    @AppStorage(MobileAppModel.DefaultsKey.hemisphere) private var hemisphere = Hemisphere.northern.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section {
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
                } header: {
                    Text("Rotation")
                } footer: {
                    Text("iOS apps can't run on a schedule in the background, so an overdue rotation happens the next time you open the app.")
                }

                Section {
                    Toggle("Match quotes to the time of year", isOn: $preferSeasonalQuotes)
                    Picker("Hemisphere", selection: $hemisphere) {
                        ForEach(Hemisphere.allCases, id: \.rawValue) { hemisphere in
                            Text(hemisphere.displayName).tag(hemisphere.rawValue)
                        }
                    }
                    .disabled(!preferSeasonalQuotes)
                } header: {
                    Text("Seasonal quotes")
                } footer: {
                    Text("Quotes tagged with a season, month, or holiday (e.g. \u{201C}winter\u{201D}, \u{201C}december\u{201D}, \u{201C}christmas\u{201D}) only appear at that time of year and are preferred while it lasts. Untagged quotes rotate year-round. Season tags flip in the southern hemisphere; month and holiday tags don't change.")
                }

                Section {
                    LabeledContent(
                        "Version",
                        value: Bundle.main.object(
                            forInfoDictionaryKey: "CFBundleShortVersionString"
                        ) as? String ?? "—"
                    )
                } header: {
                    Text("About")
                } footer: {
                    Text("Quotes, profiles, and rotation state are stored on this device as JSON files. Use Export in the Quotes tab to move the library between devices.")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
