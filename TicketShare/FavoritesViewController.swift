//
//  FavoritesViewController.swift
//  TicketShare
//
//  Created by Chen g on 05/05/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var favoritesTickets:[Ticket] = []
    let detailSegueIdentifier = "ShowTicketDetailSegue"
    
    @IBOutlet weak var favTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        self.favTable.backgroundColor = UIColor.clear
        self.title = "My Favorites"
        self.favoritesTickets = Model.instance.getUserFavoriteTickets(user: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoritesTickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath) as! FavoritesTableViewCell
        
        if self.favoritesTickets.count >= indexPath.row
        {
            let ticket = self.favoritesTickets[indexPath.row]
            
            cell.nameLabel!.text = ticket.title
            cell.amountLabel!.text = String(ticket.amount) + "x"
            cell.amountLabel.layer.borderColor = cell.amountLabel.textColor.cgColor
            cell.amountLabel.layer.borderWidth = 2.0
            cell.amountLabel.layer.cornerRadius = 6.0
            
            cell.priceLabel!.text = String(ticket.price) + "₪"
            cell.locLabel.text = ticket.address
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let result = formatter.string(from: date)
            cell.dateLabel.text = result
            
            switch ticket.eventType {
            case 1:
                cell.typeImg.image = UIImage(named: "concert")
            case 2:
                cell.typeImg.image = UIImage(named: "sports")
            case 3:
                cell.typeImg.image = UIImage(named: "festival")
            case 4:
                cell.typeImg.image = UIImage(named: "theater")
            default:
                cell.typeImg.image = UIImage(named: "unknown")
            }
        }
        
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == detailSegueIdentifier {
            let destination = segue.destination as? TicketDetailsViewController
            
            let indexPath = favTable?.indexPathForSelectedRow
            if indexPath != nil {
                destination?.selectedTicket = self.favoritesTickets[indexPath!.row]
            }
        }
    }
}
