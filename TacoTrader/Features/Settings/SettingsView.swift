import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var settings = AppSettings.shared
    @State private var showTokenField = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Backend") {
                    LabeledContent("Base URL") {
                        TextField("http://raspberrypi.local:5000", text: $settings.backendURL)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(.secondary)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    LabeledContent("Auth token") {
                        if showTokenField {
                            TextField("Bearer token", text: $settings.authToken)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.secondary)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        } else {
                            Button("Tap to reveal") { showTokenField = true }
                                .foregroundColor(.tacoBlue)
                        }
                    }
                }

                Section("Auto-refresh") {
                    HStack {
                        Text("Interval")
                        Spacer()
                        Text("\(Int(settings.refreshInterval))s")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $settings.refreshInterval, in: 5...60, step: 5)
                }

                Section("Notifications") {
                    Toggle("Redeem alerts", isOn: $settings.notificationsEnabled)
                        .tint(.tacoGreen)
                }

                Section {
                    Button(role: .destructive) {
                        settings.authToken = ""
                    } label: {
                        Label("Clear auth token", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
