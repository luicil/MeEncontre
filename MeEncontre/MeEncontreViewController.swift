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
    @IBOutlet weak var viewCarregando: UIView!
    @IBOutlet weak var activityCarregando: UIActivityIndicatorView!
    
    
    let locationManager : CLLocationManager = CLLocationManager()
    let regionRadious : CLLocationDistance = 100
    let spanMake : Double = 0.005
    let nErros : Int = 5
    let overlayLineWidth : CGFloat = 5
    let iosVer : Double = 9
    let distanceFilter : Double = 10.0
    let overlayStrokeColor : UIColor = UIColor.blueColor()
    
    var startLocation: CLLocation!
    var locations = [CLLocationCoordinate2D]()
    var pinColor : UIColor?
    var toStop : Bool = false
    var flagRastrear : Bool = true
    var removeOverlays : Bool = false
    var flagErro : Bool = false
    var contaErro1 : Int = 0
    var contaErro2 : Int = 0
    var action : actions = actions.Rastrear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.mapView.delegate = self
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        self.mapView.showsBuildings = true
        self.mapView.showsPointsOfInterest = true
        //self.mapView.showsTraffic = true
    
        self.removeOverlaysAnnotations()
        
        self.locationManager.delegate = self
        self.checkDevice()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.activityType = CLActivityType.AutomotiveNavigation
        self.locationManager.distanceFilter = self.distanceFilter
        self.locationManager.requestAlwaysAuthorization()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: CLLocation = locations[locations.count - 1]
        CLGeocoder().reverseGeocodeLocation(latestLocation, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                if !self.flagErro {
                    if self.action != actions.Nenhum {
                        self.contaErro1 += 1
                        if self.contaErro1 >= self.nErros {
                            self.contaErro1 = 0
                            self.flagErro = true
                            self.showError(error!)
                        }
                    }
                }
                return
            }
            
            if placemarks?.count > 0 {
                self.viewCarregando.hidden = true
                let pm : CLPlacemark = placemarks![0] as CLPlacemark
                if self.toStop {
                    if self.action != actions.Nenhum {
                        self.setAnnotation(pm)
                    }
                    self.action = actions.Nenhum
                } else {
                    if self.removeOverlays {
                        self.removeOverlays = false
                        self.removeOverlaysAnnotations()
                        self.setAnnotation(pm)
                    }
                    
                    let newCoordinates : CLLocationCoordinate2D = latestLocation.coordinate
                    self.locations.append(newCoordinates)
                    self.startLocation = latestLocation
                    if UIApplication.sharedApplication().applicationState == .Active {
                        let polyline = MKPolyline(coordinates: &self.locations, count: self.locations.count)
                        self.mapView.addOverlay(polyline)
                        self.centerMapOnLocation(pm.location!)
                    }
                }
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.contaErro2 += 1
        if self.contaErro2 >= self.nErros {
            self.contaErro2 = 0
            self.flagErro = true
            self.showError(error)
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Building {
            let identifier : String = "pin"
            var view : MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                view = dequeuedView
                view.pinTintColor = annotation.pinColor
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: 0, y: 0)
                view.animatesDrop = true
                view.pinTintColor = annotation.pinColor
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let pr = MKPolylineRenderer(overlay: overlay)
        if (overlay is MKPolyline) {
            pr.strokeColor = self.overlayStrokeColor
            pr.lineWidth = self.overlayLineWidth
            return pr
        }
        return pr
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Building
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(self.spanMake, self.spanMake)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: span)
        self.mapView.setRegion(region, animated: true)
        
    }
    
    func showMe(show : Bool = true) {
        self.mapView.showsUserLocation = show
        if show {
            self.mapView.userTrackingMode = MKUserTrackingMode.Follow
        } else {
            self.mapView.userTrackingMode = MKUserTrackingMode.None
        }
    }
    
    func setAnnotation(pm : CLPlacemark) {
        let title = pm.name
        let subtitle = pm.locality
        let coordinate = pm.location?.coordinate
        let build = Building(title: title!, subtitle: subtitle!, coordinate: coordinate!, pinColor: self.pinColor!)
        self.mapView.addAnnotation(build)
    }
    
    func removeOverlaysAnnotations() {
        self.startLocation = nil
        self.locations.removeAll()
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
    }
    
    func reset() {
        self.locationManager.stopUpdatingLocation()
        self.showMe(false)
        self.action = actions.Nenhum
        self.removeOverlaysAnnotations()
        self.segmentButton2.setTitle("Iniciar", forSegmentAtIndex: 0)
        self.segmentButton2.setEnabled(true, forSegmentAtIndex: 1)
        self.pinColor = nil
        self.viewCarregando.hidden = true
    }
    
    func showError(error: NSError) {
        //
        // Está dando erro mas continua a rastrear sem problemas.
        // Mensagem desabilitada.
        self.flagErro = false
        return
        
//        if self.flagErro {
//            if UIApplication.sharedApplication().applicationState == .Active {
//                let alert = UIAlertController(title: "Falha de Localização", message: "Impossível localizar\nVerifique sua conexão !\n\nErro: " + error.description + "\n\nDeseja continuar com a localização ?", preferredStyle: .Alert)
//                let OKAction = UIAlertAction(title: "Sim", style: .Default) { (action:UIAlertAction!) in
//                    self.flagErro = false
//                    return
//                }
//                alert.addAction(OKAction)
//                
//                let NOKAction = UIAlertAction(title: "Não", style: .Destructive) { (action:UIAlertAction!) in
//                    self.reset()
//                    self.flagErro = false
//                    return
//                }
//                alert.addAction(NOKAction)
//                
//                self.presentViewController(alert, animated: true, completion:nil)
//            } else {
//                self.flagErro = false
//            }
//        }
    }
    
    func checkDevice() {
        let Device = UIDevice.currentDevice()
        let iosVersion = Double(Device.systemVersion) ?? 0
        
        let iOS9 = iosVersion >= self.iosVer
        if iOS9{
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.pausesLocationUpdatesAutomatically = true
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
        self.viewCarregando.hidden = false
        switch sender.selectedSegmentIndex {
        case 0:
            if self.flagRastrear {
                self.pinColor = UIColor.greenColor()
                self.flagRastrear = false
                UIApplication.sharedApplication().idleTimerDisabled = true
                self.toStop = false
                self.action = actions.Rastrear
                self.segmentButton2.setTitle("Parar", forSegmentAtIndex: 0)
                self.segmentButton2.setEnabled(false, forSegmentAtIndex: 1)
                self.showMe(true)
                self.removeOverlays = true
                self.removeOverlaysAnnotations()
                self.locationManager.startUpdatingLocation()
            } else {
                self.pinColor = UIColor.redColor()
                self.locationManager.stopUpdatingLocation()
                self.flagRastrear = true
                UIApplication.sharedApplication().idleTimerDisabled = false
                self.toStop = true
                self.showMe(false)
                self.segmentButton2.setTitle("Iniciar", forSegmentAtIndex: 0)
                self.segmentButton2.setEnabled(true, forSegmentAtIndex: 1)
                self.locationManager.requestLocation()
            }
        case 1:
            self.showMe(true)
            self.toStop = true
            action = actions.OndeEstou
            self.pinColor = UIColor.purpleColor()
            self.locationManager.requestLocation()
        case 2:
            self.reset()
        default:
            break
        }
        sender.selectedSegmentIndex = -1
    }
}
