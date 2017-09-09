//
//  ViewController.swift
//  TicketShare
//
//  Created by dor dubnov on 2/1/17.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit
import CoreLocation

class RegisterViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate{
    var locationManager = CLLocationManager()

    @IBOutlet weak var lblRequiredPassword: UILabel!
    @IBOutlet weak var lblRequiredName: UILabel!
    @IBOutlet weak var lblRequiredEmail: UILabel!
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var lblBadEmail: UILabel!
    @IBOutlet weak var lblBadPassword: UILabel!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var imgImage: UIImageView!
    var bIsEmailValid: Bool = false
    var bIsPasswordValid: Bool = false
    var bIsFullNameValid: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.clear
        
        self.loadingSpinner.isHidden = true
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
    
    @IBAction func chooseImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.navigationBar.tintColor = .black
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
        }
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        self.imgImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismiss(animated: true, completion: nil);
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerUser(_ sender: Any) {
        self.loadingSpinner.isHidden = false
        self.loadingSpinner.startAnimating()
        
        /*self.locationManager.requestWhenInUseAuthorization()
        var currentLocation = ""
        
        // get current location
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            currentLocation = locationManager.location?.coordinate.latitude.description
        }*/
        
        if self.imgImage.image != nil {
            let imageName = self.txtEmail.text!.replacingOccurrences(of: ".", with: "_") + String(Date().timeIntervalSince1970.rounded())
            Model.instance.saveImage(image: self.imgImage.image!, name: imageName) {(url) in
                let user = User(email: self.txtEmail.text!, password: self.txtPassword.text!, fullName: self.txtFullName.text!, dateOfBirth: Date(), imageUrl: url, bIsNew: true)
                Model.instance.addUser(user: user) {(err) in
                    self.loadingSpinner.stopAnimating()
                    self.loadingSpinner.isHidden = true
                    
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
        else
        {
            let user = User(email: self.txtEmail.text!, password: self.txtPassword.text!, fullName: self.txtFullName.text!, dateOfBirth: Date(), bIsNew: true)
            Model.instance.addUser(user: user) {(err) in
                self.loadingSpinner.stopAnimating()
                self.loadingSpinner.isHidden = true
            
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
}

