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
    
    var nRequests : Int = 0
    

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
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {

        if let retorno = applicationContext["ONDEESTOU"] as? String {
            let latitude = applicationContext["LATITUDE"] as? String
            let longitude = applicationContext["LONGITUDE"] as? String
            let mapLocation = CLLocationCoordinate2DMake(Double(latitude!)!, Double(longitude!)!)
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(mapLocation, span)
            self.mapView.setRegion(region)
            self.mapView.addAnnotation(mapLocation, withPinColor: .Purple)
        }
        //self.startSession()
    }
    
    func startSession() {
        if (WCSession.isSupported()) {
            self.wSession = WCSession.defaultSession()
            self.wSession.delegate = self
            self.wSession.activateSession()
        }
    }
    

    @IBAction func actMnuIniciar() {
    }
    
    @IBAction func actMnuParar() {
    }
    
    @IBAction func actMenuOndeEstou() {
        self.nRequests += 1
        let appDic = ["ONDEESTOU":String(self.nRequests)]
        do {
            try self.wSession.updateApplicationContext(appDic)
        } catch {
            print("erro")
        }
    }
    
    @IBAction func actMnuReset() {
        self.mapView.removeAllAnnotations()
    }

}
