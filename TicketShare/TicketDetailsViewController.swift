//
//  TicketDetailsViewController.swift
//  TicketShare
//
//  Created by Shay H on 18/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit
import MapKit

class TicketDetailsViewController: UIViewController {
    var selectedTicket = Ticket(seller: "", title: "", price: 0, amount: 0, address: "", description: "", imageUrl: nil)
    
    @IBOutlet weak var ticketImageView: UIImageView!
    @IBOutlet weak var addrField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var descField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.titleField.text = selectedTicket.title
        self.descField.text = selectedTicket.description
        self.amountField.text = String(selectedTicket.amount)
        self.priceField.text = String(selectedTicket.price) + "₪"
        self.addrField.text = selectedTicket.address
        
        if let imUrl = selectedTicket.imageUrl{
            Model.instance.getImage(urlStr: imUrl, callback: { (image) in
                self.ticketImageView!.image = image
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
