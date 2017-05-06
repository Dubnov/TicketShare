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
    case Bought = 2
}

class MyTicketsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var forSaleTickets:[Ticket] = []
    var soldTickets:[Purchase] = []
    var boughtTickets:[Purchase] = []
    
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
        NotificationCenter.default.addObserver(self, selector:
            #selector(self.forSellTicketsListDidUpdate), name: NSNotification.Name(rawValue: notifyTicketsForSell),object: nil)
        
        
        Model.instance.getCurrentUserPurchases() {
            
        }
        //Model.instance.getCurrentUserTicketsSold()
        //Model.instance.getCurrentUserTicketsBought()
        Model.instance.getCurrentUserTicketsForSell()
    }

    @objc func soldTicketsListDidUpdate(notification:NSNotification){
        self.soldTickets = notification.userInfo?["tickets"] as! [Purchase]
        
        if (mySegmentedControl.selectedSegmentIndex == TicketCategory.Sold.rawValue) {
            self.myTableView.reloadData()
        }
    }
    
    @objc func boughtTicketsListDidUpdate(notification:NSNotification){
        self.boughtTickets = notification.userInfo?["tickets"] as! [Purchase]
        
        if (mySegmentedControl.selectedSegmentIndex == TicketCategory.Bought.rawValue) {
            self.myTableView.reloadData()
        }
    }
    
    @objc func forSellTicketsListDidUpdate(notification:NSNotification){
        self.forSaleTickets = notification.userInfo?["tickets"] as! [Ticket]
        
        if (mySegmentedControl.selectedSegmentIndex == TicketCategory.ForSale.rawValue) {
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
        case TicketCategory.Bought.rawValue:
            numberOfRowInSection = boughtTickets.count
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
            myCell.lblTitle?.text = forSaleTickets[indexPath.row].title
            myCell.lblPrice?.text = forSaleTickets[indexPath.row].price.description
            myCell.lblAmount?.text = forSaleTickets[indexPath.row].amount.description
            myCell.lblBuyerSellerLabel.text = ""
            myCell.lblBuyerSellerValue.text = ""
            myCell.lblDateValue.text = ""
            myCell.lblDateLabel.isHidden = true
            break
        case TicketCategory.Sold.rawValue:
            myCell.lblTitle?.text = soldTickets[indexPath.row].ticketTitle
            myCell.lblPrice?.text = soldTickets[indexPath.row].purchaseCost.description
            myCell.lblAmount?.text = soldTickets[indexPath.row].ticketAmount.description
            myCell.lblBuyerSellerLabel.text = "Buyer:"
            myCell.lblBuyerSellerValue.text = soldTickets[indexPath.row].buyer
            myCell.lblDateValue.text = soldTickets[indexPath.row].purchaseDate.description
            myCell.lblDateLabel.isHidden = false
            break
        case TicketCategory.Bought.rawValue:
            myCell.lblTitle?.text = boughtTickets[indexPath.row].ticketTitle
            myCell.lblPrice?.text = boughtTickets[indexPath.row].purchaseCost.description
            myCell.lblAmount?.text = boughtTickets[indexPath.row].ticketAmount.description
            myCell.lblBuyerSellerLabel.text = "Seller:"
            myCell.lblBuyerSellerValue.text = boughtTickets[indexPath.row].seller
            myCell.lblDateValue.text = boughtTickets[indexPath.row].purchaseDate.description
            myCell.lblDateLabel.isHidden = false
            break
        default:
            break
        }
        
        return myCell
    }

    
    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if mySegmentedControl.selectedSegmentIndex == TicketCategory.ForSale.hashValue {
            return true
        }
        
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EditTicketDetailSegue" {
            let destination = segue.destination as? TicketDetailsViewController
            
            let indexPath = self.myTableView.indexPathForSelectedRow
            destination?.selectedTicket = (self.forSaleTickets[indexPath!.row])
            destination?.bIsFromMyTickets = true;
        }
    }
    
    @IBAction func unwindToMyTickets(segue: UIStoryboardSegue) {
    }

}
