//
//  ProfileViewController.swift
//  TicketShare
//
//  Created by Chen g on 17/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class ProfileDetailsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lblInvalidName: UILabel!
    @IBOutlet weak var lblInvalidEmail: UILabel!
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    @IBOutlet weak var btnSave: UIButton!
    
    var bIsEmailValid: Bool = true
    var bIsFullNameValid: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        self.txtFullName.text = Model.instance.getCurrentAuthUserName()
        self.txtEmail.text = Model.instance.getCurrentAuthUserEmail()
        
        if (Model.instance.isLoginFromFacebook()) {
            self.txtFullName.isEnabled = false
            self.txtEmail.isEnabled = false
            self.btnSave.isHidden = true
        }
        
        self.txtFullName.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        self.txtEmail.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
    }
    
    func textFieldDidChanged(_ textField: UITextField) {
        
        switch textField {
        case txtEmail:
            validateEmail()
            break
        case txtFullName:
            validateFullName()
            break
        default:
            break
        }
        
        //btnEdit.isEnabled = bIsEmailValid && bIsFullNameValid
        btnSave.isEnabled = bIsEmailValid && bIsFullNameValid
    }
    
    func validateEmail() {
        if (txtEmail.text == "") {
            lblInvalidEmail.isHidden = false
            bIsEmailValid = false
        } else if (!isValidEmail(testStr: txtEmail.text!)) {
            lblInvalidEmail.isHidden = false
            bIsEmailValid = false
        } else {
            lblInvalidEmail.isHidden = true
            bIsEmailValid = true
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func validateFullName() {
        if (txtFullName.text != "") {
            bIsFullNameValid = true
            lblInvalidName.isHidden = true
        } else {
            bIsFullNameValid = false
            lblInvalidName.isHidden = false
        }
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        //self.loadingSpinner.isHidden = false
        //self.loadingSpinner.startAnimating()
        
        Model.instance.editUser(name: self.txtFullName.text!, email: self.txtEmail.text!) {(err) in
            //self.loadingSpinner.stopAnimating()
            //self.loadingSpinner.isHidden = true
            
            if err == nil {
                self.performSegue(withIdentifier: "unwindToMyProfilePage", sender: self)
            } else {
                print("Chen")
                let alertController = UIAlertController(title: "Details Update Error", message: err?.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func editUserProfileDetails(_ sender: Any) {
        //self.loadingSpinner.isHidden = false
        //self.loadingSpinner.startAnimating()
        
        Model.instance.editUser(name: self.txtFullName.text!, email: self.txtEmail.text!) {(err) in
            //self.loadingSpinner.stopAnimating()
            //self.loadingSpinner.isHidden = true
            
            if err == nil {
                self.performSegue(withIdentifier: "unwindToMyProfilePage", sender: self)
            } else {
                print("Chen")
                let alertController = UIAlertController(title: "Details Update Error", message: err?.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
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
    }
 

}
