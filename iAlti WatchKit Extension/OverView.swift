//
//  OverView.swift
//  iAlti WatchKit Extension
//
//  Created by Lukas Wheldon on 10.10.15.
//

import SwiftUI

struct OverViewLine: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    var name: String
    var value: Double
    var decimals: Int
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 10))
            Spacer()
            Text("\(value, specifier: "%.\(decimals)f")")
                .font(.system(size: 20))
                .foregroundColor(userSettings.colors[userSettings.colorSelection])
        }
    }
}

struct OverView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        VStack {
            HStack {
                Text("Barometer")
                    .font(.system(size: 15))
                if globals.isAltimeterStarted {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .scaleEffect(0.5)
                        .foregroundColor(.red)
                } else {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .scaleEffect(0.5)
                        .foregroundColor(.gray)
                }
            }
            OverViewLine(name: "Pressure [hPa]", value: globals.pressure, decimals: 2)
            OverViewLine(name: "Altitude MSL [m]", value: globals.barometricAltitude, decimals: 0)
            OverViewLine(name: "Vertical Speed [m/s]", value: globals.speedV, decimals: 1)
            Divider()
            HStack {
                Text("GPS")
                    .font(.system(size: 15))
                if globals.isLocationStarted {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .scaleEffect(0.5)
                        .foregroundColor(.red)
                } else {
                    Image(systemName: "circle.fill")
                        .imageScale(.small)
                        .scaleEffect(0.5)
                        .foregroundColor(.gray)
                }
            }
            OverViewLine(name: "Altitude MSL [m]", value: LocationManager.shared.lastLocation?.altitude ?? 0.0, decimals: 0)
            OverViewLine(name: "Horizontal Speed [m/s]", value: LocationManager.shared.lastLocation?.speed ?? 0.0, decimals: 1)
        }
        .navigationBarTitle("iAlti")
    }
}

struct OverView_Previews: PreviewProvider {
    static var previews: some View {
        OverView()
            .environmentObject(UserSettings())
            .environmentObject(Globals())
    }
}
