//
//  InterfaceController.swift
//  MeEncontre WatchKit Extension
//
//  Created by Luicil Fernandes on 10/04/16.
//  Copyright © 2016 Luicil Fernandes. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation


class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: WKInterfaceMap!
    
    let locationManager: CLLocationManager = CLLocationManager()
    var mapLocation: CLLocationCoordinate2D?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 5
        self.locationManager.delegate = self
        self.locationManager.requestLocation()
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentLocation = locations[0]
        let lat = currentLocation.coordinate.latitude
        let long = currentLocation.coordinate.longitude
        
        self.mapLocation = CLLocationCoordinate2DMake(lat, long)
        
        let span = MKCoordinateSpanMake(0.1, 0.1)
        
        let region = MKCoordinateRegionMake(self.mapLocation!, span)
        self.mapView.setRegion(region)
        
        self.mapView.addAnnotation(self.mapLocation!,
                                     withPinColor: .Red)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print(error.description)
    }
    
    @IBAction func actSlider(value: Float) {
        
        let degrees:CLLocationDegrees = CLLocationDegrees(value / 10)
        
        let span = MKCoordinateSpanMake(degrees, degrees)
        let region = MKCoordinateRegionMake(mapLocation!, span)
        
        mapView.setRegion(region)
    }
    

}
