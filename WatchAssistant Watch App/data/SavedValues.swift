// Licensed under the MIT License, created by DeveloLongScript on GitHub

import Foundation
import SwiftUI

var savedValues = SavableValues()
var tempValues = TempValues()

func SaveData() {
    let encoder = JSONEncoder()
    let jsonencoded = try? encoder.encode(savedValues)
    UserDefaults.standard.set(jsonencoded, forKey: "savedSettings")
}

func GetData() {
    if let data = UserDefaults.standard.data(forKey: "savedSettings") {
            if let decoded = try? JSONDecoder().decode(SavableValues.self, from: data) {
                savedValues = decoded
                return
            }
        }
}

struct TempValues: Codable {
    var startToken: String = ""
}

struct SavableValues: Codable {
    var warningRemoved: Bool = false
    var host: String = ""
}
