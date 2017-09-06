//
//  LoginViewController.swift
//  TicketShare
//
//  Created by Chen g on 16/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class LoginViewController: UIViewController, UITextFieldDelegate, LoginButtonDelegate {

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        self.txtPassword.delegate = self
        self.txtEmail.delegate = self

        let frame = CGRect(x: 100, y: 520, width: 180, height: 40)
        let loginButton = LoginButton(frame: frame, readPermissions: [ReadPermission.email, ReadPermission.publicProfile])
        view.addSubview(loginButton)
        loginButton.delegate = self
        
        // TODO - Delete this
        /*self.txtEmail.text = "chen.goren94@gmail.com"
        self.txtPassword.text = "123123"
        self.login(5)*/

        // Do any additional setup after loading the view.
        self.loadingSpinner.isHidden = true
        self.txtPassword.isSecureTextEntry = true
        self.txtEmail.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        self.txtPassword.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        
        self.txtEmail.becomeFirstResponder()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
    }
    
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .cancelled:
            break
        case .failed:
            break
        case .success:
            let accessToken = AccessToken.current
            guard let accessTokenString = accessToken?.authenticationToken else { return }
            
            
            let req = GraphRequest.init(graphPath: "/me", parameters: ["fields":"id,name,email,picture"])
            req.start { (urlResponse, requestResult) in
                switch requestResult {
                case .failed(let error):
                    print("error in graph request:", error)
                    break
                case .success(let graphResponse):
                    if let responseDictionary = graphResponse.dictionaryValue {
                        Model.instance.loginFromFB(accessToken: accessTokenString, email: responseDictionary["email"] as! String, name: responseDictionary["name"] as! String!, pictureUrl: (((responseDictionary["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String)!) {(err) in
                            if err == nil {
                                self.performSegue(withIdentifier: "performSegueToMain", sender: self)
                            } else {
                                let alertController = UIAlertController(title: "Facebook Login Error", message: err as! String, preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
            break
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("logout")
    }
    
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
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
        self.loadingSpinner.isHidden = false
        self.loadingSpinner.startAnimating()
        
        let email = txtEmail.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let password = txtPassword.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        Model.instance.loginUser(email: email, password: password) { (error) in
            self.loadingSpinner.stopAnimating()
            self.loadingSpinner.isHidden = true
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
        self.txtEmail.text?.removeAll()
        self.txtPassword.text?.removeAll()
        self.btnLogin.isEnabled = false
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
