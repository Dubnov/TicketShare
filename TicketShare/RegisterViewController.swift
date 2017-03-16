//
//  ViewController.swift
//  TicketShare
//
//  Created by dor dubnov on 2/1/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var lblBadEmail: UILabel!
    @IBOutlet weak var lblBadPassword: UILabel!
    var bIsEmailValid: Bool = false
    var bIsPasswordValid: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        txtPassword.isSecureTextEntry = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func emailEditingDidEndValidate(_ sender: Any) {
        if isValidEmail(testStr: self.txtEmail.text!) {
            bIsEmailValid = true
        }
        else {
            bIsEmailValid = false
        }
        
        lblBadEmail.isHidden = bIsEmailValid
    }

    @IBAction func passwordEditingDidEndValidate(_ sender: Any) {
        let passLength: Int = (self.txtPassword.text?.characters.count)!
        
        if passLength >= 6 && passLength <= 12 {
            bIsPasswordValid = true
        } else {
            bIsPasswordValid = false
        }
        
        lblBadPassword.isHidden = bIsPasswordValid
    }
    
    
    @IBAction func registerUser(_ sender: Any) {
        self.txtFullName.endEditing(true)
        self.txtPassword.endEditing(true)
        self.txtEmail.endEditing(true)
        
        if bIsEmailValid && bIsPasswordValid && !((txtFullName.text?.isEmpty)!) {
            // Register - Check if email exists in db, if so - print message
            // if not, save details and move to main page
            let user = User(email: self.txtEmail.text!, password: self.txtPassword.text!, fullName: self.txtFullName.text!)
            Model.instance.addUser(user: user)
        } else {
            let alertController = UIAlertController(title: "Register Error", message: "one or more of the fields are incorrect", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil)
            alertController.addAction(alertAction)
            
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}

