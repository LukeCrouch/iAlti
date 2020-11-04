//
//  mainView.swift
//  iAlti WatchKit Extension
//
//  Created by Lukas Wheldon on 10.10.20.
//

import SwiftUI

struct mainView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        VStack {
            if globals.relativeAltitude > 999 || globals.relativeAltitude < -999 {
                Text("\((globals.relativeAltitude + userSettings.offset) / 1000, specifier: "%.2f")")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    .transition(.opacity)
            }
            else {
                Text("\(globals.relativeAltitude + userSettings.offset, specifier: "%.0f")")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    .transition(.opacity)
            }
            Spacer()
            Text("Relative Altitude [m]")
                .font(.system(size: 15))
            Divider()
            if globals.glideRatio > 99 || globals.glideRatio < 0 {
                Image(systemName: "face.smiling")
                    .font(.system(size: 60))
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    .transition(.opacity)
            }s
            else {
                Text("\(globals.glideRatio, specifier: "%.0f")")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
                    .transition(.opacity)
            }
            Text("Glide Ratio")
                .font(.system(size: 15))
        }
        .navigationBarTitle("iAlti")
    }
}

struct mainView_Previews: PreviewProvider {
    static var previews: some View {
        mainView()
            .environmentObject(UserSettings())
            .environmentObject(Globals())
    }
}
