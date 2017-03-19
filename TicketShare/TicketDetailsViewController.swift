//
//  TicketDetailsViewController.swift
//  TicketShare
//
//  Created by Shay H on 18/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit
import MapKit

class TicketDetailsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var selectedTicket = Ticket(seller: "", title: "", price: 0, amount: 0, address: "", description: "", imageUrl: nil)
    var locationManager = CLLocationManager()
    var currLocation = CLLocation()
    var selectedMapItem = MKMapItem()
    var selectedLatitude: Double = 0
    var selectedLongitude: Double = 0
    var selectedLoaded = false
    var currloaded = false
    
    @IBOutlet weak var navigateButton: UIButton!
    @IBOutlet weak var sellerField: UITextField!
    @IBOutlet weak var ticketImageView: UIImageView!
    @IBOutlet weak var addrField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var descField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    
    @IBAction func navigateClick(_ sender: UIButton) {
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        self.selectedMapItem.openInMaps(launchOptions: options)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.titleField.text = selectedTicket.title
        self.descField.text = selectedTicket.description
        self.amountField.text = String(selectedTicket.amount)
        self.priceField.text = String(selectedTicket.price) + "₪"
        self.addrField.text = selectedTicket.address
        self.sellerField.text = selectedTicket.seller
        
        if let imUrl = selectedTicket.imageUrl{
            Model.instance.getImage(urlStr: imUrl, callback: { (image) in
                self.ticketImageView!.image = image
            })
        }
        
        self.mapView.delegate = self
        
        // Convert address to latitude&longitude
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.addrField.text!) { (placemarksOptional, error) -> Void in
            if let placemarks = placemarksOptional {
                if let location = placemarks.first?.location {
                    print("latitude:\(location.coordinate.latitude)")
                    print("longitude:\(location.coordinate.longitude)")
                    self.selectedLatitude = location.coordinate.latitude
                    self.selectedLongitude = location.coordinate.longitude
                    self.selectedLoaded = true
                    let coordinates = CLLocationCoordinate2DMake(self.selectedLatitude,
                                                                 self.selectedLongitude)
                    let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                    self.selectedMapItem = MKMapItem(placemark: placemark)
                    self.selectedMapItem.name = self.selectedTicket.title
                    
                    self.navigateButton.isEnabled = true
                    let span = MKCoordinateSpanMake(0.0075, 0.0075)
                    let eventCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    let region = MKCoordinateRegion(center: eventCoordinate, span: span)
                    self.mapView.setRegion(region, animated: true)
                    let eventAnnotation = MKPointAnnotation()
                    eventAnnotation.coordinate = eventCoordinate
                    self.mapView.addAnnotation(eventAnnotation)
                    self.calcDriveDetails()
                }
            }
        }
        
        // 	ask for user's permission to use location
        self.locationManager.requestWhenInUseAuthorization()
        
        // get current location
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            currLocation = locationManager.location!
            self.currloaded = true
            calcDriveDetails()
            let currLocAnnotation = MKPointAnnotation()
            currLocAnnotation.coordinate = currLocation.coordinate
            self.mapView.addAnnotation(currLocAnnotation)
        }
    }
    
    func calcDriveDetails() {
        if selectedLoaded && currloaded {
            let request: MKDirectionsRequest = MKDirectionsRequest()
            let placemark = MKPlacemark(coordinate: currLocation.coordinate, addressDictionary: nil)
            let mapitem = MKMapItem(placemark: placemark)
            request.source = mapitem
            request.destination = self.selectedMapItem
            request.transportType = .automobile
        
            let directions = MKDirections(request: request)
            directions.calculate(completionHandler: {(response, error) in
                if let routeResponse = response?.routes {
                    if let route = routeResponse.first {
                        if route.distance < 1000.0 {
                            self.distLabel.text = NSString(format: "%.2f m", route.distance) as String
                        }
                        else {
                            self.distLabel.text = NSString(format: "%.2f Km", route.distance/1000) as String
                        }
                        
                        if route.expectedTravelTime/60 < 60 {
                            self.etaLabel.text = NSString(format: "%.0f Minutes", route.expectedTravelTime/60) as String
                        }
                        else {
                            self.etaLabel.text = NSString(format: "%.1f Hours", route.expectedTravelTime/60/60) as String
                        }
                    
                        self.mapView.addOverlays([route.polyline])
                        if self.mapView.overlays.count == 1 {
                            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                                           edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                                           animated: false)
                        }
                        else {
                            let polylineBoundingRect =  MKMapRectUnion(self.mapView.visibleMapRect,
                                                                       route.polyline.boundingMapRect)
                            self.mapView.setVisibleMapRect(polylineBoundingRect,
                                                           edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                                           animated: false)
                        }
                    }
                } else if let _ = error {
                
                }
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
    
        return MKOverlayRenderer()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
