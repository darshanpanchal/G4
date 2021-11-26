//
//  LocationSingleton.swift
//  G4VL
//
//  Created by Foamy iMac7 on 11/08/2017.
//  Copyright © 2017 Foamy iMac7. All rights reserved.
//

import UIKit
import CoreLocation

class LocationSingleton: NSObject, CLLocationManagerDelegate {
    
    let BATCH_SIZE = 50
    let DURATION_IN_SECONDS = 120
    var lastSent : Date?
    static let sharedInstance = LocationSingleton()
    var arrayOfLocations : Locations = []
    let dateFormatter = DateFormatter()
    var locationManager: CLLocationManager = CLLocationManager()
    var isRunning = false
    var jobID = 0
    
    func start() {
        
        if isRunning {
            return
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        isRunning = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //add location to array
        
        
        for location in locations {
            
            
            let dateString = dateFormatter.string(from: location.timestamp)
            
            let location = Location(long: "\(location.coordinate.longitude)", latt: "\(location.coordinate.latitude)", geoLocatedAt: dateString)
            
            
            
            arrayOfLocations.append(location)
        }
        
        
        if lastSent == nil || Int(lastSent!.timeIntervalSinceNow) >= DURATION_IN_SECONDS  || arrayOfLocations.count >= BATCH_SIZE {
            //send locations when any of the following are satisfied,
            //no locations have been sent
            //4 minutes or more since the last locations were sent
            //Batch limit has been reached
            
            lastSent = Date()
            print("sending locations");
            
            Requests.sendLocationUpdates(jobID: jobID, locations: arrayOfLocations)
            
            arrayOfLocations = []
        }
        
    }
    
    
    func jobComplete() {
        //job has complete, send any remaining locations
        
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        
        isRunning = false
        
        if arrayOfLocations.count > 0 {
           
            Requests.sendLocationUpdates(jobID: jobID, locations: arrayOfLocations)
            
            arrayOfLocations = []
        }
     
    }
    
}
