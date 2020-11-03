//
//  iAltiApp.swift
//  iAlti WatchKit Extension
//
//  Created by Lukas Wheldon on 29.09.20.
//

import SwiftUI

class UserSettings: ObservableObject {
    @Published var colors = [Color.green, Color.white, Color.red, Color.blue, Color.orange, Color.yellow, Color.pink, Color.purple]
    @Published var colorSelection = 0
    @Published var qnh = 1013.25
    @Published var offset = 0.0
}

class Globals: ObservableObject {
    @Published var pressure = 0.0
    @Published var isAltiStarted = false
    @Published var isLocationStarted = false
    @Published var gpsAltitude: CLLocationDistance = 0.0
    @Published var barometricAltitude = 0.0
    @Published var relativeAltitude = 0.0
    @Published var speedV = 0.0
    @Published var speedH = 0.0
    @Published var glideRatio = 0.0
}

@main
struct iAltiApp: App {
    @StateObject var globals = Globals()
    @StateObject var userSettings = UserSettings()
    
    var body: some Scene {
        WindowGroup {
                ContentView()
                    .environmentObject(globals)
                    .environmentObject(userSettings)
        }
    }
}
