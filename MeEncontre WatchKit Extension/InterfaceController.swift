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
    
    var wSession : WCSession!
    
    //var nRequests : Int = 0
    

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
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        let retorno = message["TIPOMSG"] as? String
        let latitude = message["LATITUDE"] as? String
        let longitude = message["LONGITUDE"] as? String
        
        let mapLocation = CLLocationCoordinate2DMake(Double(latitude!)!, Double(longitude!)!)
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(mapLocation, span)
        self.mapView.setRegion(region)
        //self.mapView.addAnnotation(mapLocation, withPinColor: .Purple)
        if retorno == "ONDEESTOU" {
            self.mapView.addAnnotation(mapLocation, withImageNamed: "userlocationsf.png", centerOffset: CGPoint(x: 0, y: 0))
        } else if retorno == "PARAR" {
            self.mapView.addAnnotation(mapLocation, withPinColor: .Red)
        } else if retorno == "INICIAR" {
            self.mapView.addAnnotation(mapLocation, withPinColor: .Green)
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
        self.sndMessage(["TIPOMSG":"INICIAR"])
    }
    
    @IBAction func actMnuParar() {
        self.sndMessage(["TIPOMSG":"PARAR"])
    }
    
    @IBAction func actMenuOndeEstou() {
        self.sndMessage(["TIPOMSG":"ONDEESTOU"])

    }
    
    @IBAction func actMnuReset() {
        self.mapView.removeAllAnnotations()
    }

}
