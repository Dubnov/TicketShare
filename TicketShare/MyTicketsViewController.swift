//
//  MyTicketsViewController.swift
//  TicketShare
//
//  Created by Chen g on 23/04/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

enum TicketCategory: Int {
    case ForSale = 0
    case Sold = 1
    case Purchased = 2
}

class MyTicketsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var forSaleTickets:[Purchase] = []
    var soldTickets:[Purchase] = []
    var purchasedTickets:[Purchase] = []
    
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
        
        //TODO: Call same method for "for sale" tickets
        NotificationCenter.default.addObserver(self, selector:
            #selector(self.soldTicketsListDidUpdate), name: NSNotification.Name(rawValue: notifyTicketsSoldUpdate),object: nil)
        NotificationCenter.default.addObserver(self, selector:
            #selector(self.boughtTicketsListDidUpdate), name: NSNotification.Name(rawValue: notifyBoughtTicketsUpdate),object: nil)
        
        Model.instance.getCurrentUserTicketsSold()
        Model.instance.getCurrentUserTicketsBought()
    }

    @objc func soldTicketsListDidUpdate(notification:NSNotification){
        self.soldTickets = notification.userInfo?["tickets"] as! [Purchase]
        
        if (mySegmentedControl.selectedSegmentIndex == TicketCategory.Sold.rawValue) {
            self.myTableView.reloadData()
        }
    }
    
    @objc func boughtTicketsListDidUpdate(notification:NSNotification){
        self.purchasedTickets = notification.userInfo?["tickets"] as! [Purchase]
        
        if (mySegmentedControl.selectedSegmentIndex == TicketCategory.Purchased.rawValue) {
            self.myTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        self.myTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRowInSection = 0
        
        switch (mySegmentedControl.selectedSegmentIndex)
        {
        case TicketCategory.ForSale.rawValue:
            numberOfRowInSection = forSaleTickets.count
            break
        case TicketCategory.Sold.rawValue:
            numberOfRowInSection = soldTickets.count
            break
        case TicketCategory.Purchased.rawValue:
            numberOfRowInSection = purchasedTickets.count
            break
        default:
            break
        }
        
        return numberOfRowInSection
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellHeight: CGFloat
        
        switch (mySegmentedControl.selectedSegmentIndex)
        {
        case TicketCategory.ForSale.rawValue:
            cellHeight = 70
            break
        default:
            cellHeight = 105
            break
        }
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! PurchaseTableViewCell
        
        // TODO: Replace with real values
        switch (mySegmentedControl.selectedSegmentIndex)
        {
        case TicketCategory.ForSale.rawValue:
            myCell.lblTitle?.text = forSaleTickets[indexPath.row].ticketId
            myCell.lblPrice?.text = forSaleTickets[indexPath.row].purchaseCost.description
            myCell.lblAmount?.text = forSaleTickets[indexPath.row].ticketAmount.description
            myCell.lblBuyerSellerLabel.text = ""
            myCell.lblBuyerSellerValue.text = ""
            myCell.lblDateValue.text = ""
            myCell.lblDateLabel.isHidden = true
            break
        case TicketCategory.Sold.rawValue:
            myCell.lblTitle?.text = soldTickets[indexPath.row].ticketId
            myCell.lblPrice?.text = soldTickets[indexPath.row].purchaseCost.description
            myCell.lblAmount?.text = soldTickets[indexPath.row].ticketAmount.description
            myCell.lblBuyerSellerLabel.text = "Buyer:"
            myCell.lblBuyerSellerValue.text = soldTickets[indexPath.row].buyer
            myCell.lblDateValue.text = soldTickets[indexPath.row].purchaseDate.description
            myCell.lblDateLabel.isHidden = false
            break
        case TicketCategory.Purchased.rawValue:
            myCell.textLabel?.text = purchasedTickets[indexPath.row].ticketId
            myCell.lblPrice?.text = purchasedTickets[indexPath.row].purchaseCost.description
            myCell.lblAmount?.text = purchasedTickets[indexPath.row].ticketAmount.description
            myCell.lblBuyerSellerLabel.text = "Seller:"
            myCell.lblBuyerSellerValue.text = purchasedTickets[indexPath.row].seller
            myCell.lblDateValue.text = purchasedTickets[indexPath.row].purchaseDate.description
            myCell.lblDateLabel.isHidden = false
            break
        default:
            break
        }
        
        return myCell
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
