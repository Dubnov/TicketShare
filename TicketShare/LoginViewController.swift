//
//  LoginViewController.swift
//  TicketShare
//
//  Created by Chen g on 16/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtPassword.isSecureTextEntry = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: Any) {
        if (txtEmail.text?.characters.count == 0) {
            
        } else if (txtPassword.text?.characters.count == 0) {
            
        } else {
            Model.instance.loginUser(email: txtEmail.text!, password: txtPassword.text!)
            
            // TODO: Call this only if login user succeeded
            self.performSegue(withIdentifier: "performSegueToMain", sender: self)
        }
    }
    
    @IBAction func unwindToLogin(segue:UIStoryboardSegue){
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
