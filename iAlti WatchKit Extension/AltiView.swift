//
//  AltiView.swift
//  iAlti WatchKit Extension
//
//  Created by Lukas Wheldon on 10.10.20.
//

import SwiftUI
import CoreMotion

struct AltiView: View {
    let altimeter = CMAltimeter()
    @State var relativeAltitude = 0.0
    @State var pressure =  0.0
    
    func startAltimeter() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            switch CMAltimeter.authorizationStatus() {
            case .notDetermined: // Handle state before user prompt
                print("Awaiting user prompt...")
            //fatalError("Awaiting user prompt...")
            case .restricted: // Handle system-wide restriction
                fatalError("Authorization restricted!")
            case .denied: // Handle user denied state
                fatalError("Authorization denied!")
            case .authorized: // Ready to go!
                let _ = print("Authorized!")
            @unknown default:
                fatalError("Unknown Authorization Status")
            }
            self.altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) {(data,error) in
                if let trueData = data {
                    print(trueData)
                    relativeAltitude = trueData.relativeAltitude.doubleValue
                    pressure = trueData.pressure.doubleValue
                }
            }
            
        }
    }
    
    var body: some View {
        Text("Pressure")
            .fontWeight(.bold)
        Text("\(pressure, specifier: "%.2f")")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Color.green)
        Divider()
        Text("Relative Altitude")
            .fontWeight(.bold)
        Text("\(relativeAltitude, specifier: "%.0f")")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Color.green)
    }
}

struct AltiView_Previews: PreviewProvider {
    static var previews: some View {
        AltiView()
    }
}
