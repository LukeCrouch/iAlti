//
//  SettingsView.swift
//  iAlti WatchKit Extension
//
//  Created by Lukas Wheldon on 14.10.20.
//

import SwiftUI
import Combine

struct NumberEntryField : View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    @State var enteredValue: String
    @State var value: Double
    let qnh: Bool
    
    var body: some View {
        return TextField("", text: $enteredValue)
            .font(.system(size: 20))
            .foregroundColor(userSettings.colors[userSettings.colorSelection])
            //.frame(width: 100, height: 20, alignment: .center)
            .onReceive(Just(enteredValue)) { typedValue in
                if let newValue = Double(typedValue) {
                    self.value = newValue
                }
            }.onAppear(perform:{self.enteredValue = "\(self.value)"})
            .onDisappear(perform: {if qnh {
                userSettings.qnh = self.value}
            else {
                userSettings.offset = self.value
            }
            })
    }
}

struct SettingsView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    let Colors = ["Green", "White", "Red", "Blue", "Orange", "Yellow", "Pink", "Purple"]
    
    var body: some View {
        VStack {
            HStack {
                Text("QNH")
                Spacer()
                NumberEntryField(enteredValue: "", value: userSettings.qnh, qnh: true)
                Spacer()
                Text("hPa")
            }
            HStack {
                Text("Offset")
                Spacer()
                NumberEntryField(enteredValue: "", value: userSettings.offset, qnh: false)
                Spacer()
                Text("m")
            }
            HStack {
                Text("Color")
                    .padding(.top)
                Spacer()
                Picker("", selection: $userSettings.colorSelection, content: {
                        ForEach(0 ..< Colors.count) {
                            index in Text(Colors[index]).tag(index)
                        }})
                    .foregroundColor(userSettings.colors[userSettings.colorSelection])
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
