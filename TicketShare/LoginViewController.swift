//
//  ViewController.swift
//  TicketShare
//
//  Created by dor dubnov on 2/1/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    var bIsEmailValid: Bool = false
    var bIsPasswordValid: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
    }

    @IBAction func passwordEditingDidEndValidate(_ sender: Any) {
        let passLength: Int = (self.txtPassword.text?.characters.count)!
        
        if passLength >= 6 && passLength <= 12 {
            bIsPasswordValid = true
        } else {
            bIsPasswordValid = false
        }
    }

    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}

