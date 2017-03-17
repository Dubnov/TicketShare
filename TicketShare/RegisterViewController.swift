//
//  ViewController.swift
//  TicketShare
//
//  Created by dor dubnov on 2/1/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var lblRequiredPassword: UILabel!
    @IBOutlet weak var lblRequiredName: UILabel!
    @IBOutlet weak var lblRequiredEmail: UILabel!
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var lblBadEmail: UILabel!
    @IBOutlet weak var lblBadPassword: UILabel!
    var bIsEmailValid: Bool = false
    var bIsPasswordValid: Bool = false
    var bIsFullNameValid: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        txtPassword.isSecureTextEntry = true
        self.txtFullName.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        self.txtEmail.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        self.txtPassword.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
    }


    func textFieldDidChanged(_ textField: UITextField) {
        
        switch textField {
        case txtEmail:
            validateEmail()
            break
        case txtPassword:
            validatePassword()
            break
        case txtFullName:
            validateFullName()
            break
        default:
            break
        }
        
        if (bIsEmailValid && bIsPasswordValid && bIsFullNameValid) {
            btnRegister.isEnabled = true
            btnRegister.alpha = 1
        } else {
            btnRegister.isEnabled = false
            btnRegister.alpha = 0.5
        }
    }

    func validateEmail() {
        if (txtEmail.text == "") {
            lblRequiredEmail.isHidden = false
            lblBadEmail.isHidden = false
            bIsEmailValid = false
        } else if (!isValidEmail(testStr: txtEmail.text!)) {
            lblRequiredEmail.isHidden = true
            lblBadEmail.isHidden = false
            bIsEmailValid = false
        } else {
            lblRequiredEmail.isHidden = true
            lblBadEmail.isHidden = true
            bIsEmailValid = true
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func validatePassword() {
        if (txtPassword.text == "") {
            lblRequiredPassword.isHidden = false
            lblBadPassword.isHidden = false
            bIsPasswordValid = false
        } else if ((txtPassword.text?.characters.count)! < 6 ||
                   (txtPassword.text?.characters.count)! > 12) {
            lblRequiredPassword.isHidden = true
            lblBadPassword.isHidden = false
            bIsPasswordValid = false
        } else {
            lblRequiredPassword.isHidden = true
            lblBadPassword.isHidden = true
            bIsPasswordValid = true
        }
    }

    func validateFullName() {
        if (txtFullName.text != "") {
            bIsFullNameValid = true
            lblRequiredName.isHidden = true
        } else {
            bIsFullNameValid = false
            lblRequiredName.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerUser(_ sender: Any) {
        // Register - Check if email exists in db, if so - print message
        // if not, save details and move to main page
        let user = User(email: self.txtEmail.text!, password: self.txtPassword.text!, fullName: self.txtFullName.text!)
        Model.instance.addUser(user: user) {(err) in
            if err == nil {
                self.performSegue(withIdentifier: "performSegueToMain", sender: self)
            } else {
                let alertController = UIAlertController(title: "Sign Up Error", message: err?.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

