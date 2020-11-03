//
//  ControlsView.swift
//  iAlti WatchKit Extension
//
//  Created by Lukas Wheldon on 10.10.20.
//

import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    @Binding var view: Int
    @State private var showModal = false
    private let activityType = CLActivityType.airborne
    
    func startLocation() {
        switch LocationManager.shared.locationStatus {
        case .notDetermined:
            print("CL: Awaiting user prompt...")
        //fatalError("Awaiting CL user prompt...")
        case .restricted:
            fatalError("CL Authorization restricted!")
        case .denied:
            fatalError("CL Authorization denied!")
        case .authorizedAlways:
            print("CL Authorized!")
        case .authorizedWhenInUse:
            print("CL Authorized when in use!")
        case .none:
            print("CL Authorization None!")
        @unknown default:
            fatalError("Unknown CL Authorization Status!")
        }
        LocationManager.shared.start()
        globals.isLocationStarted = false
    }
    
    func stopAltimeter(){
        Altimeter.shared.stopRelativeAltitudeUpdates()
    }
    
    func startAltimeter() {
        if Altimeter.isRelativeAltitudeAvailable() {
            switch Altimeter.authorizationStatus() {
            case .notDetermined: // Handle state before user prompt
                print("CM: Awaiting user prompt...")
            //fatalError("Awaiting CM user prompt...")
            case .restricted: // Handle system-wide restriction
                fatalError("CM Authorization restricted!")
            case .denied: // Handle user denied state
                fatalError("CM Authorization denied!")
            case .authorized: // Ready to go!
                let _ = print("CM Authorized!")
            @unknown default:
                fatalError("Unknown CM Authorization Status!")
            }
            Altimeter.shared.startRelativeAltitudeUpdates(to: OperationQueue.main) {(data,error) in
                if let trueData = data {
                    print(trueData)
                    globals.relativeAltitude = trueData.relativeAltitude.doubleValue
                    globals.pressure = trueData.pressure.doubleValue * 10
                    globals.barometricAltitude =  8400 * (userSettings.qnh - globals.pressure) / userSettings.qnh
                }
            }
            globals.isAltiStarted = true
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Button(action: {
                        print("Start")
                        startAltimeter()
                        startLocation()
                        view = (view + 1) % 1
                    }) {
                        Image(systemName: "play.fill")
                            .foregroundColor(.green)
                            .font(.title)
                    }
                    Text("Start")
                }
                VStack {
                    Button(action: {
                        print("Stop")
                        stopAltimeter()
                        LocationManager.shared.stop()
                        globals.isLocationStarted = false
                    }) {
                        Image(systemName: "stop.fill")
                            .foregroundColor(.red)
                            .font(.title)
                    }
                    Text("Stop")
                }
            }
            HStack {
                VStack {
                    Button(action: {
                        print("Reset")
                        stopAltimeter()
                        startAltimeter()
                        view = (view + 1) % 1
                    })
                    {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title)
                    }
                    Text("Reset")
                }
                VStack {
                    Button(action: {
                        print("Settings")
                        showModal.toggle()
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.yellow)
                            .font(.title)
                    }
                    Text("Settings")
                }.sheet(isPresented: $showModal) {
                    SettingsView()
                        .environmentObject(globals)
                        .environmentObject(userSettings)
                        .toolbar(content: {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { self.showModal = false }
                            }
                        })
                }
            }
        }.navigationBarTitle("Controls")
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(view: .constant(0))
    }
}
