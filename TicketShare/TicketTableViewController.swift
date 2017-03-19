//
//  TicketTableViewController.swift
//  TicketShare
//
//  Created by Shay H on 18/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class TicketTableViewController: UITableViewController {
    var ticketsList = [Ticket]()
    let detailSegueIdentifier = "ShowTicketDetailSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:
            #selector(self.ticketsListDidUpdate), name: NSNotification.Name(rawValue: notifyTicketListUpdate),object: nil)
        
        Model.instance.getAllTicketsAndObserve()
    }

    @objc func ticketsListDidUpdate(notification:NSNotification){
        self.ticketsList = notification.userInfo?["tickets"] as! [Ticket]
        self.tableView!.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ticketsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TicketTableViewCell", for: indexPath) as! TicketTableViewCell
        
        cell.nameLabel!.text = self.ticketsList[indexPath.row].title
        cell.amountLabel!.text = String(self.ticketsList[indexPath.row].amount)
        cell.priceLabel!.text = String(self.ticketsList[indexPath.row].price) + "₪"
        
        if let imUrl = self.ticketsList[indexPath.row].imageUrl{
            Model.instance.getImage(urlStr: imUrl, callback: { (image) in
                cell.ticketImageView!.image = image
            })
        }
        
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == detailSegueIdentifier,
            let destination = segue.destination as? TicketDetailsViewController,
            let clinicIdex = self.tableView.indexPathForSelectedRow?.row
        {
            destination.selectedTicket = self.ticketsList[clinicIdex]
        }
    }
}
