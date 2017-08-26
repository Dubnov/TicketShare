//
//  PreferencesViewController.swift
//  TicketShare
//
//  Created by dor dubnov on 8/19/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class PreferencesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var options:[PreferencesOption] = [PreferencesOption]()
    var choices:[PreferencesOption] = [PreferencesOption]()
    
    @IBOutlet weak var prefTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear        
        self.prefTable.backgroundColor = UIColor.clear
        
        Model.instance.getUserPreferences() { userPrefs in
            self.choices = userPrefs
            self.options = Model.preferencesOptions
            
            self.prefTable.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            Model.instance.saveUserPreferences(preferences: self.choices)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrefTableCell", for: indexPath) as! PreferencesTableViewCell
        cell.lblSuggestion.text = self.options[indexPath.row].value
        cell.btnCheck.tag = indexPath.row
        cell.btnCheck.setOn(false, animated: false)
        
        for userPref in self.choices {
            if (self.options[indexPath.row].value == userPref.value) {
                cell.btnCheck.setOn(true, animated: false)
            }
        }
        
        cell.btnCheck.addTarget(self, action: #selector(switchChanged), for: UIControlEvents.valueChanged)
        cell.data = self.options[indexPath.row]
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PreferencesTableViewCell
        cell.btnCheck.setOn(!cell.btnCheck.isOn, animated: true)
    }
    
    func switchChanged(sender:UISwitch) {
        if (sender.isOn) {
            self.choices.append(self.options[sender.tag])
        } else {
            for (index, item) in self.choices.enumerated() {
                if (item.value == self.options[sender.tag].value) {
                    self.choices.remove(at: index)
                    break
                }
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
