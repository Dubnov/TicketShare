//
//  MyTicketsViewController.swift
//  TicketShare
//
//  Created by Chen g on 23/04/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class MyTicketsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var forSaleTickets:[String] = []
    var soldTickets:[String] = []
    var purchasedTickets:[String] = []
    
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBOutlet weak var myTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //TODO: Fill this array from model
        forSaleTickets = ["Chen", "Dor", "Shay"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        
        // TODO: Fill arrays from model
        switch (mySegmentedControl.selectedSegmentIndex)
        {
        case 0:
            forSaleTickets = ["sale1","sale2","sale3"]
            break
        case 1:
            soldTickets = ["sold1","sold2","sold3","sold4"]
            break
        case 2:
             purchasedTickets = ["purchased"]
            break
        default:
            break
        }
        
        myTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRowInSection = 0
        
        switch (mySegmentedControl.selectedSegmentIndex)
        {
        case 0:
            numberOfRowInSection = forSaleTickets.count
            break
        case 1:
            numberOfRowInSection = soldTickets.count
            break
        case 2:
            numberOfRowInSection = purchasedTickets.count
            break
        default:
            break
        }
        
        return numberOfRowInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        switch (mySegmentedControl.selectedSegmentIndex)
        {
        case 0:
            myCell.textLabel?.text = forSaleTickets[indexPath.row]
            break
        case 1:
            myCell.textLabel?.text = soldTickets[indexPath.row]
            break
        case 2:
            myCell.textLabel?.text = purchasedTickets[indexPath.row]
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
