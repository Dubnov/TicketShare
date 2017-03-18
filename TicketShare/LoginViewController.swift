//
//  LoginViewController.swift
//  TicketShare
//
//  Created by Chen g on 16/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.txtPassword.isSecureTextEntry = true
        self.txtEmail.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        self.txtPassword.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
    }

    func textFieldDidChanged(_ textField: UITextField) {
        if self.txtEmail.text != "" && self.txtPassword.text != "" {
            self.btnLogin.isEnabled = true
            self.btnLogin.alpha = 1
        } else {
            self.btnLogin.isEnabled = false
            self.btnLogin.alpha = 0.5
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(_ sender: Any) {
        Model.instance.loginUser(email: txtEmail.text!, password: txtPassword.text!) { (error) in
            if error == nil {
                self.performSegue(withIdentifier: "performSegueToMain", sender: self)
            } else {
                let alertController = UIAlertController(title: "Login Error", message: "the email or password is incorrect", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
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
