//
//  MeEncontreViewController.swift
//  MeEncontre
//
//  Created by Luicil Fernandes on 10/04/16.
//  Copyright © 2016 Luicil Fernandes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MeEncontreViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    enum actions : Int {
        case Localizacao = 1
        case Rastrear = 2
        case OndeEstou = 3
        case Nenhum = 0
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentButton1: UISegmentedControl!
    @IBOutlet weak var segmentButton2: UISegmentedControl!
    
    let locationManager : CLLocationManager = CLLocationManager()
    let regionRadious : CLLocationDistance = 200
    
    var toStop : Bool = false
    var flagRastrear : Bool = false
    var removeOverlays : Bool = false
    var action : actions = actions.Localizacao
    var pinColor : UIColor = UIColor.redColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.mapView.delegate = self
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                return
            }
            
            if placemarks?.count > 0 {
                if self.toStop {
                    self.locationManager.stopUpdatingLocation()
                }
                let pm : CLPlacemark = placemarks![0] as CLPlacemark
                switch self.action {
                case actions.Localizacao:
                    if self.removeOverlays {
                        self.mapView.removeAnnotations(self.mapView.annotations)
                        self.mapView.removeOverlays(self.mapView.overlays)
                    }
                    self.centerMapOnLocation(pm.location!)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = pm.location!.coordinate
                    annotation.title = pm.name
                    annotation.subtitle = pm.subLocality
                    self.mapView.addAnnotation(annotation)
                case actions.Rastrear:
                    if let oldLocationNew = oldLocation as CLLocation?{
                        let oldCoordinates = oldLocationNew.coordinate
                        let newCoordinates = newLocation.coordinate
                        var area = [oldCoordinates, newCoordinates]
                        let polyline = MKPolyline(coordinates: &area, count: area.count)
                        self.mapView.addOverlay(polyline)
                    }
                case actions.OndeEstou:
                    self.centerMapOnLocation(pm.location!)
                default:
                    break
                }
                if self.toStop {
                    self.action = actions.Nenhum
                }
            }
        })
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alert = UIAlertController(title: "Falha de Localização", message: "Impossível localizar\nVerifique sua conexão !\n\nErro: " + error.description, preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
            return
        }
        alert.addAction(OKAction)
        
        self.presentViewController(alert, animated: true, completion:nil)

    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MKPointAnnotation {
            let identifier = "pin"
            var view : MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
            }
            view.pinTintColor = pinColor
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let pr = MKPolylineRenderer(overlay: overlay)
        if (overlay is MKPolyline) {
            //let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.redColor()
            pr.lineWidth = 5
            return pr
        }
        return pr
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadious * 2.0, regionRadious * 2.0)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showMe(show : Bool = true) {
        self.mapView.showsUserLocation = show
        if show {
            self.mapView.userTrackingMode = MKUserTrackingMode.Follow
        } else {
            self.mapView.userTrackingMode = MKUserTrackingMode.None
        }

    }
    
    
    @IBAction func actSegmentButton1(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.mapView.mapType = MKMapType.Standard
        case 1:
            self.mapView.mapType = MKMapType.Satellite
        case 2:
            self.mapView.mapType = MKMapType.Hybrid
        default:
            self.mapView.mapType = MKMapType.Standard
        }
    }
    
    @IBAction func actSegmentButton2(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.showMe(false)
            self.toStop = true
            self.removeOverlays = true
            self.pinColor = UIColor.blueColor()
            action = actions.Localizacao
            self.locationManager.startUpdatingLocation()
            self.segmentButton2.setEnabled(true, forSegmentAtIndex: 1)
        case 1:
            self.toStop = flagRastrear
            flagRastrear = !flagRastrear
            self.removeOverlays = false
            if flagRastrear {
                self.segmentButton2.setTitle("Parar", forSegmentAtIndex: 1)
                self.segmentButton2.setEnabled(false, forSegmentAtIndex: 0)
                self.segmentButton2.setEnabled(false, forSegmentAtIndex: 2)
                action = actions.Rastrear
                self.locationManager.startUpdatingLocation()
            } else {
                self.segmentButton2.setTitle("Rastrear", forSegmentAtIndex: 1)
                self.segmentButton2.setEnabled(false, forSegmentAtIndex: 1)
                self.segmentButton2.setEnabled(true, forSegmentAtIndex: 0)
                self.segmentButton2.setEnabled(true, forSegmentAtIndex: 2)
                self.pinColor = UIColor.redColor()
                self.action = actions.Localizacao
            }
            self.showMe(flagRastrear)
             self.locationManager.startUpdatingLocation()
        case 2:
            self.showMe(true)
            self.toStop = true
            action = actions.OndeEstou
            self.locationManager.startUpdatingLocation()
        default:
            break
        }
        sender.selectedSegmentIndex = -1
    }
    
    

}
