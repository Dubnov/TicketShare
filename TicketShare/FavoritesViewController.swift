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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        self.title = "My Favorites"
        self.favoritesTickets = Model.instance.getUserFavTickets(user: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoritesTickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath) as! FavoritesTableViewCell
        
        myCell.lblTitle?.text = favoritesTickets[indexPath.row].title
        myCell.lblPrice?.text = favoritesTickets[indexPath.row].price.description
        myCell.lblAmount?.text = favoritesTickets[indexPath.row].amount.description
        
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
