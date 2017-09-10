//
//  TicketDetailsViewController.swift
//  TicketShare
//
//  Created by Shay H on 18/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit
import MapKit

class TicketDetailsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
    var selectedTicket:Ticket? = nil
    var selectedTicketID:String? = nil
    var selectedTicketBuyerID:String? = nil
    var locationManager = CLLocationManager()
    var currLocation = CLLocation()
    var selectedMapItem = MKMapItem()
    var selectedLatitude: Double = 0
    var selectedLongitude: Double = 0
    var selectedLoaded = false
    var currloaded = false
    var bIsFromMyTickets = false
    
    @IBOutlet weak var btnRemoveFromFav: UIButton!
    @IBOutlet weak var btnAddToFav: UIButton!
    @IBOutlet weak var btnBuyTicket: UIButton!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var ticketImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addrLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var sellerLabel: UILabel!
    @IBOutlet weak var amountPriceLabel: UILabel!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtMulSign: UILabel!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var lblEditAmount: UILabel!
    @IBOutlet weak var lblEditPrice: UILabel!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var lblSoldBoughtBy: UILabel!
    @IBOutlet weak var lblTitleRequired: UILabel!
    @IBOutlet weak var lblAmountRequired: UILabel!
    @IBOutlet weak var lblAddressRequired: UILabel!
    @IBOutlet weak var lblPriceRequired: UILabel!
    @IBOutlet var btnEditButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        
        if self.selectedTicketID != nil {
            Model.instance.getTicketByIdFromFirebase(ticketID: (self.selectedTicketID)!) {(err, ticket) in
                self.selectedTicket = ticket;
                self.initView()
            }
        } else {
            self.initView()
        }
        
        self.txtPrice.delegate = self
        self.txtAmount.delegate = self
    }
    
    func initView() {
        if let ticket = selectedTicket {
            
            
            // Do any additional setup after loading the view.
            self.titleLabel.text = selectedTicket?.title
            self.descLabel.text = selectedTicket?.description
            self.amountPriceLabel.text = String(ticket.amount) + " x " + String(ticket.price) + "₪"
            self.addrLabel.text = selectedTicket?.address
            
            Model.instance.getUserByIdFromFirebase(userId: (selectedTicket?.seller)!) {(err, user) in
                self.sellerLabel.text = ""
                if (user != nil) {
                    self.sellerLabel.text = user?.fullName
                } else if (err == nil){
                    self.sellerLabel.text = self.selectedTicket?.seller
                }
            }
            
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
                
                if (Model.instance.isTicketInUserFavorites(ticket: selectedTicket!) == true) {
                    self.btnRemoveFromFav.isHidden = false
                    self.btnAddToFav.isHidden = true
                } else {
                    self.btnRemoveFromFav.isHidden = true
                    self.btnAddToFav.isHidden = false
                }
            } else {
                self.btnBuyTicket.isHidden = true
                self.btnAddToFav.isHidden = true
                self.btnRemoveFromFav.isHidden = true
                self.txtPrice.isHidden = false
                self.txtPrice.text = self.selectedTicket?.price.description
                self.txtAmount.isHidden = false
                self.txtAmount.text = self.selectedTicket?.amount.description
                self.txtTitle.isHidden = false
                self.txtTitle.text = self.selectedTicket?.title
                self.txtDescription.isHidden = false
                self.txtDescription.text = self.selectedTicket?.description
                self.txtAddress.isHidden = false
                self.txtAddress.text = self.selectedTicket?.address
                self.addrLabel.isHidden = true
                self.descLabel.isHidden = true
                self.titleLabel.isHidden = true
                self.amountPriceLabel.isHidden = true
                self.lblEditPrice.isHidden = false
                self.lblEditAmount.isHidden = false
                self.txtMulSign.isHidden = false
                self.lblPriceRequired.isHidden = false
                self.lblAmountRequired.isHidden = false
                self.lblTitleRequired.isHidden = false
                self.lblAddressRequired.isHidden = false
            }
        }
        
        if self.selectedTicketID != nil {
            self.navBar.isHidden = false
            self.btnEditButton.isEnabled = false
            self.btnEditButton.title = ""
            self.btnBuyTicket.isHidden = true
            self.btnAddToFav.isHidden = true
            self.btnRemoveFromFav.isHidden = true
            
            if self.selectedTicketBuyerID != nil {
                self.lblSoldBoughtBy.text = "Bought by:"
                Model.instance.getUserByIdFromFirebase(userId: (self.selectedTicketBuyerID)!) {(err, user) in
                    self.sellerLabel.text = ""
                    if (user != nil) {
                        self.sellerLabel.text = user?.fullName
                    }
                }
            }
        }
    }
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        Model.instance.addFavoriteTicket(ticket: selectedTicket!)
        self.btnAddToFav.isHidden = true
        self.btnRemoveFromFav.isHidden = false
    }
    
    @IBAction func removeFromFavorites(_ sender: UIButton) {
        Model.instance.removeFavoriteTicket(ticketId: selectedTicket!.id)
        self.btnRemoveFromFav.isHidden = true
        self.btnAddToFav.isHidden = false
    }
    
    @IBAction func backToMyTickets(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToMyTickets", sender: self)
    }
    
    @IBAction func saveEditedTicket(_ sender: Any) {
        var errorMessage: String = ""
        
        if self.txtTitle.text?.characters.count == 0 {
            errorMessage = errorMessage + "Title Can't Be Empty\n"
        }
        if self.txtAddress.text?.characters.count == 0 {
            errorMessage = errorMessage + "Address Can't Be Empty\n"
        }
        if self.txtAmount.text?.characters.count == 0 {
            errorMessage = errorMessage + "Amount Can't Be Empty\n"
        }
        if self.txtPrice.text?.characters.count == 0 {
            errorMessage = errorMessage + "Price Can't Be Empty\n"
        }
        
        if (errorMessage != "") {
            errorMessage = errorMessage.substring(to: errorMessage.index(before: errorMessage.endIndex))
            let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.selectedTicket?.title = self.txtTitle.text!
            self.selectedTicket?.amount = Int(self.txtAmount.text!)!
            self.selectedTicket?.price = Double(self.txtPrice.text!)!
            self.selectedTicket?.address = self.txtAddress.text!
            self.selectedTicket?.description = self.txtDescription.text!
        
            Model.instance.editTicket(ticket: selectedTicket!)
            self.performSegue(withIdentifier: "unwindToMyTickets", sender: self)
        }
    }
    
    @IBAction func buyTicket(_ sender: Any) {
        Model.instance.buyTicket(ticket: selectedTicket!) {(err) in
            if (err != nil) {
                // Model.instance.getAllTicketsAndObserve()
            }
        }
        
        self.performSegue(withIdentifier: "unwindToDiscover", sender: self)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtPrice {
            if ((self.txtPrice.text?.characters.count == 0 && ((string == ".") || (string == "0"))) ||
                (string == "." && (self.txtPrice.text?.contains("."))!)) {
                return false
            } else if ("0123456789".contains(string)) {
                return true
            } else if (string == "") {
                return true
            } else {
                return false
            }
        } else {
            if self.txtAmount.text?.characters.count == 0 && string == "0" {
                return false
            } else {
                let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
                let compSepByCharInSet = string.components(separatedBy: aSet)
                let numberFiltered = compSepByCharInSet.joined(separator: "")
                return string == numberFiltered
            }
        }
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
