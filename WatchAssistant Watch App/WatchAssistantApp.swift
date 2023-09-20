// Licensed under the MIT License, created by DeveloLongScript on GitHub

import SwiftUI

@main
struct WatchAssistant_Watch_AppApp: App {
    init() {
        GetData()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if savedValues.warningRemoved == false {
                    UnOfficalWarning()
                } else {
                    WelcomePage()
                }
                
            }.tint(.purple)
        }
    }
}
