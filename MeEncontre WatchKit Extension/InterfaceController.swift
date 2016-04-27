//
//  InterfaceController.swift
//  MeEncontre WatchKit Extension
//
//  Created by Luicil Fernandes on 10/04/16.
//  Copyright © 2016 Luicil Fernandes. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var mapView: WKInterfaceMap!
    @IBOutlet var sliderMap: WKInterfaceSlider!
    
    var wSession : WCSession!
    var lastLocation: CLLocationCoordinate2D?
    var locations : [Building] = [Building]()
    
    var iniciado : Bool = false
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        self.startSession()
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func setMapRegion(mapLocation : CLLocationCoordinate2D) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(mapLocation, span)
        self.mapView.setRegion(region)
    }
    
    func addLocation(location : CLLocationCoordinate2D, imageName : String, pinColor : UIColor) {
        self.locations.append(Building(title: "", subtitle: "", coordinate: location, pinColor: pinColor, tipoPin: "P", imageName: imageName))
        var pColor : WKInterfaceMapPinColor?
        switch pinColor {
        case UIColor.redColor():
            pColor = WKInterfaceMapPinColor.Red
        case UIColor.greenColor():
            pColor = WKInterfaceMapPinColor.Green
        case UIColor.purpleColor():
            pColor = WKInterfaceMapPinColor.Purple
        default:
            pColor = WKInterfaceMapPinColor.Green
        }
        if self.locations.count <= 5 {
            self.addAnnotation(location, imageName: imageName, pinColor: pColor!)
        } else {
            var mapLocation : CLLocationCoordinate2D = self.locations[0].coordinate
            self.addAnnotation(mapLocation, imageName: imageName, pinColor: pColor!)
            let cotaPos : Int = self.locations.count / 4
            for i in 1...3 {
                let pos = i + cotaPos
                mapLocation = self.locations[pos].coordinate
                self.addAnnotation(mapLocation, imageName: imageName, pinColor: pColor!)
            }
            mapLocation = self.locations[4].coordinate
            self.addAnnotation(mapLocation, imageName: imageName, pinColor: pColor!)
        }
    }
    
    func addAnnotation(mapLocation : CLLocationCoordinate2D, imageName : String, pinColor : WKInterfaceMapPinColor) {
        dispatch_async(dispatch_get_main_queue()) {
            if imageName == "" {
                self.mapView.addAnnotation(mapLocation, withPinColor: pinColor)
                
            } else {
                self.mapView.addAnnotation(mapLocation, withImageNamed: imageName, centerOffset: CGPoint(x: 0, y: 0))
            }
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let retorno = message["TIPOMSG"] as? String
        let latitude = message["LATITUDE"] as? String
        let longitude = message["LONGITUDE"] as? String
        let mapLocation = CLLocationCoordinate2DMake(Double(latitude!)!, Double(longitude!)!)
        self.lastLocation = mapLocation
        if retorno == "ONDEESTOU" {
            dispatch_async(dispatch_get_main_queue()) {
                self.setMapRegion(mapLocation)
                self.addLocation(mapLocation, imageName: "userlocationsf.png", pinColor: UIColor.greenColor())
                //self.mapView.addAnnotation(mapLocation, withImageNamed: "userlocationsf.png", centerOffset: CGPoint(x: 0, y: 0))
            }
        } else if retorno == "PARAR" {
            self.addLocation(mapLocation, imageName: "", pinColor: UIColor.redColor())
//            dispatch_async(dispatch_get_main_queue()) {
//                self.mapView.addAnnotation(mapLocation, withPinColor: .Red)
//            }
        } else if retorno == "INICIAR" {
            self.locations.removeAll()
            self.addLocation(mapLocation, imageName: "", pinColor: UIColor.greenColor())
//            dispatch_async(dispatch_get_main_queue()) {
//                //self.locations.append(Building(title: "", subtitle: "", coordinate: mapLocation, pinColor: UIColor.greenColor(), tipoPin: "P"))
//                self.setMapRegion(mapLocation)
//                self.mapView.addAnnotation(mapLocation, withPinColor: .Green)
//            }
        } else if retorno == "RASTREAR" {
            self.addLocation(mapLocation, imageName: "traco.png", pinColor: UIColor.greenColor())
//            dispatch_async(dispatch_get_main_queue()) {
//                self.mapView.addAnnotation(mapLocation, withImageNamed: "traco.png", centerOffset: CGPoint(x: 0, y: 0))
//            }
        }
    }
    
    func startSession() {
        if (WCSession.isSupported()) {
            self.wSession = WCSession.defaultSession()
            self.wSession.delegate = self
            self.wSession.activateSession()
        }
    }
    
    func sndMessage(message: [String : AnyObject]) {
        self.wSession.sendMessage(message,
            replyHandler: { reply in
                //
            },
            errorHandler: { error in
                print(error.localizedDescription)
        })
    }
    
    func reset() {
        self.iniciado = false
        self.sliderMap.setValue(1.0)
        //self.actSliderMap(1.0)
        self.mapView.removeAllAnnotations()
    }
    
    @IBAction func actMnuIniciar() {
        if !self.iniciado {
            self.iniciado = true
            self.reset()
            self.sndMessage(["TIPOMSG":"INICIAR"])
        }
    }
    
    @IBAction func actMnuParar() {
        if self.iniciado {
            self.sndMessage(["TIPOMSG":"PARAR"])
        }
        self.iniciado = false
    }
    
    @IBAction func actMenuOndeEstou() {
        self.sndMessage(["TIPOMSG":"ONDEESTOU"])

    }
    
    @IBAction func actMnuReset() {
        self.reset()
    }
    
    @IBAction func actSliderMap(value: Float) {
        if self.lastLocation != nil {
            let degrees:CLLocationDegrees = CLLocationDegrees(value / 10)
            let span = MKCoordinateSpanMake(degrees, degrees)
            let region = MKCoordinateRegionMake(self.lastLocation!, span)
            self.mapView.setRegion(region)
        }
    }
    

}
