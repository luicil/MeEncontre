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
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let retorno = message["TIPOMSG"] as? String
        let latitude = message["LATITUDE"] as? String
        let longitude = message["LONGITUDE"] as? String
        let mapLocation = CLLocationCoordinate2DMake(Double(latitude!)!, Double(longitude!)!)
        self.lastLocation = mapLocation
        if retorno == "ONDEESTOU" {
            dispatch_async(dispatch_get_main_queue()) {
                self.setMapRegion(mapLocation)
                self.mapView.addAnnotation(mapLocation, withImageNamed: "userlocationsf.png", centerOffset: CGPoint(x: 0, y: 0))
            }
        } else if retorno == "PARAR" {
            dispatch_async(dispatch_get_main_queue()) {
                self.mapView.addAnnotation(mapLocation, withPinColor: .Red)
            }
        } else if retorno == "INICIAR" {
            dispatch_async(dispatch_get_main_queue()) {
                self.setMapRegion(mapLocation)
                self.mapView.addAnnotation(mapLocation, withPinColor: .Green)
            }
        } else if retorno == "RASTREAR" {
            dispatch_async(dispatch_get_main_queue()) {
                self.mapView.addAnnotation(mapLocation, withImageNamed: "traco.png", centerOffset: CGPoint(x: 0, y: 0))
            }
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
    
    @IBAction func actMnuIniciar() {
        if !self.iniciado {
            self.iniciado = true
            self.mapView.removeAllAnnotations()
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
        self.iniciado = false
        self.mapView.removeAllAnnotations()
    }
    
    @IBAction func actSliderMap(value: Float) {
        let degrees:CLLocationDegrees = CLLocationDegrees(value / 10)
        let span = MKCoordinateSpanMake(degrees, degrees)
        let region = MKCoordinateRegionMake(self.lastLocation!, span)
        self.mapView.setRegion(region)
    }
    

}
