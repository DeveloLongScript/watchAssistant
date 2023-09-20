// Licensed under the MIT License, created by DeveloLongScript on GitHub

import SwiftUI

struct MinimalSettings: View {
    @State private var clearDialog = false
    var body: some View {
            List {
                Section(header: Text("App Info")) {
                    Text("Version: " + AppInfoObj.version)
                }
                Section(header: Text("Misc")) {
                    Button("Clear App Data") {
                        UserDefaults.standard.removeObject(forKey: "savedSettings")
                        clearDialog = true
                    }.alert("Sucessfully cleared data", isPresented: $clearDialog) {}
                }
            }.navigationTitle("Settings")
    }
}
