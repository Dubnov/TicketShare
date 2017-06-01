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
    var selectedTicket:Ticket? = nil
    var locationManager = CLLocationManager()
    var currLocation = CLLocation()
    var selectedMapItem = MKMapItem()
    var selectedLatitude: Double = 0
    var selectedLongitude: Double = 0
    var selectedLoaded = false
    var currloaded = false
    var bIsFromMyTickets = false
    
    @IBOutlet weak var btnBuyTicket: UIButton!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var ticketImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addrLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var amountPriceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        if let ticket = selectedTicket {
            
            
            // Do any additional setup after loading the view.
            self.titleLabel.text = selectedTicket?.title
            self.descLabel.text = selectedTicket?.description
            self.amountPriceLabel.text = String(ticket.amount) + " x " + String(ticket.price) + "₪"
            self.addrLabel.text = selectedTicket?.address
            self.sellerLabel.text = selectedTicket?.seller
            
            if let imUrl = selectedTicket?.imageUrl{
                Model.instance.getImage(urlStr: imUrl, callback: { (image) in
                    self.ticketImageView!.image = image
                })
            }
            
            self.mapView.delegate = self
            
            // Convert address to latitude&longitude
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(self.addrLabel.text!) { (placemarksOptional, error) -> Void in
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
                        self.selectedMapItem.name = self.selectedTicket?.title
                        let span = MKCoordinateSpanMake(0.0075, 0.0075)
                        let eventCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                        let region = MKCoordinateRegion(center: eventCoordinate, span: span)
                        self.mapView.setRegion(region, animated: true)
                        let eventAnnotation = MKPointAnnotation()
                        eventAnnotation.coordinate = eventCoordinate
                        self.mapView.addAnnotation(eventAnnotation)
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
                let currLocAnnotation = MKPointAnnotation()
                currLocAnnotation.coordinate = currLocation.coordinate
                self.mapView.addAnnotation(currLocAnnotation)
            }
            
            if !self.bIsFromMyTickets {
                self.navBar.isHidden = true
            } else {
                self.btnBuyTicket.isHidden = true
            }
        }
    }
    
    @IBAction func backToMyTickets(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToMyTickets", sender: self)
    }
    
    @IBAction func saveEditedTicket(_ sender: Any) {
        // TODO - Call edit ticket function
        self.performSegue(withIdentifier: "unwindToMyTickets", sender: self)
    }
    
    @IBAction func buyTicket(_ sender: Any) {
        // TODO - Call buy ticket function
        Model.instance.buyTicket(ticket: selectedTicket!)
        self.performSegue(withIdentifier: "unwindToDiscover", sender: self)
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
