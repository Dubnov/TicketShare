//
//  SearchTicketsViewController.swift
//  TicketShare
//
//  Created by Chen g on 22/04/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class SearchTicketsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {

    var ticketsSearchResults:Array<Ticket>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        if self.species == nil {
            self.speciesSearchResults = nil
            return
        }
        self.speciesSearchResults = self.species!.filter({( aSpecies: StarWarsSpecies) -> Bool in
            // to start, let's just search by name
            return aSpecies.name!.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
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
