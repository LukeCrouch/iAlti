//
//  ControlsView.swift
//  iAlti WatchKit Extension
//
//  Created by Lukas Wheldon on 10.10.20.
//

import SwiftUI
import CoreMotion
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "Purpose Key")
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var lastLocation: CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }
    
    //let objectWillChange = PassthroughSubject<Void, Never>()
    
    private let locationManager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        print(#function, location)
    }
    
    func stopLocation() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func startLocation() {
        switch CLAuthorizationStatus(rawValue: 0) {
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
        self.locationManager.startUpdatingLocation()
    }
}

struct ControlsView: View {
    @EnvironmentObject var globals: Globals
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var locationManager = LocationManager()
    @Binding var view: Int
    @State private var showModal = false
    private let altimeter = CMAltimeter()
    private let activityType = CLActivityType.airborne
    
    func stopAltimeter() {
        altimeter.stopRelativeAltitudeUpdates()
        globals.isAltiStarted = false
    }
    
    func startAltimeter() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            switch CMAltimeter.authorizationStatus() {
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
            globals.isAltiStarted = true
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) {(data,error) in
                if let trueData = data {
                    print(trueData)
                    globals.relativeAltitude = trueData.relativeAltitude.doubleValue
                    globals.pressure = trueData.pressure.doubleValue * 10
                    globals.barometricAltitude =  8400 * (userSettings.qnh - globals.pressure) / userSettings.qnh
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Button(action: {
                        print("Start")
                        self.startAltimeter()
                        locationManager.startLocation()
                        globals.isLocationStarted = true
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
                        self.stopAltimeter()
                        locationManager.stopLocation()
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
                        self.stopAltimeter()
                        self.startAltimeter()
                        globals.isLocationStarted = true
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