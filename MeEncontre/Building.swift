//
//  Building.swift
//  TesteLocation
//
//  Created by Luicil Fernandes on 05/04/16.
//  Copyright © 2016 Luicil Fernandes. All rights reserved.
//

import UIKit
import MapKit

class Building: NSObject, MKAnnotation {
    let title : String?
    let subtitle: String?
    let coordinate : CLLocationCoordinate2D
    let pinColor : UIColor
    var tipoPin : String = "P"
    var imageName : String = ""
    
    init(title: String, subtitle: String , coordinate: CLLocationCoordinate2D, pinColor : UIColor, tipoPin : String = "P", imageName : String = "") {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.pinColor = pinColor
        self.tipoPin = tipoPin
        self.imageName = imageName
        super.init()
    }
    
    func mapItem() -> MKMapItem {
        let placemark = MKPlacemark(coordinate: self.coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = self.title
        return mapItem
    }
    
    override var description: String {
        get {
            return "Name: \(title) - Coordinate(\(coordinate))"
        }
    }
    
}
