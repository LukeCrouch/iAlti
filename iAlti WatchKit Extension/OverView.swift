//
//  OverView.swift
//  iAlti WatchKit Extension
//
//  Created by Lukas Wheldon on 10.10.15.
//

import SwiftUI

struct OverView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        VStack {
            indicatorLine(name: "Barometer")
            OverViewLine(name: "Pressure [hPa]", value: globals.pressure, decimals: 2)
            OverViewLine(name: "Altitude MSL [m]", value: globals.barometricAltitude, decimals: 0)
            OverViewLine(name: "Vertical Speed [km/h]", value: globals.speedV, decimals: 1)
            Divider()
            indicatorLine(name: "GPS")
            OverViewLine(name: "Altitude MSL [m]", value: globals.gpsAltitude, decimals: 0)
            OverViewLine(name: "Horizontal Speed [km/h]", value: globals.speedH, decimals: 1)
        }
        .navigationBarTitle("iAlti")
    }
}

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

struct indicatorLine: View {
    @EnvironmentObject var globals: Globals
    @State private var toggle = false
    var name: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 15))
            if globals.isLocationStarted {
                Image(systemName: "circle.fill")
                    .imageScale(.small)
                    .scaleEffect(0.5)
                    .foregroundColor(.red)
                    .opacity(toggle ? 0 : 1)
                    .onAppear() {
                        toggle.toggle()}
                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).speed(1))
            }
            
            else {
                Image(systemName: "circle.fill")
                    .imageScale(.small)
                    .scaleEffect(0.5)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct OverView_Previews: PreviewProvider {
    static var previews: some View {
        OverView()
    }
}
