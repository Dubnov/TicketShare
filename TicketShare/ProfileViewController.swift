//
//  ProfileViewController.swift
//  TicketShare
//
//  Created by Chen g on 17/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        self.txtFullName.text = Model.instance.getCurrentAuthUserName()
        self.txtEmail.text = Model.instance.getCurrentAuthUserEmail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        Model.instance.signOut()
    }
 

}
