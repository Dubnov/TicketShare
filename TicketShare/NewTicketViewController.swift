//
//  NewTicketViewController.swift
//  TicketShare
//
//  Created by Chen g on 17/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit
import GooglePlaces

class NewTicketViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, GMSAutocompleteViewControllerDelegate  {

    @IBOutlet weak var txtEventType: UITextField!
    @IBOutlet weak var dropdownEventType: UIPickerView!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtEventAddress: UITextField!
    @IBOutlet weak var lblTitleRequired: UILabel!
    @IBOutlet weak var lblAmountRequired: UILabel!
    @IBOutlet weak var lblPriceRequired: UILabel!
    @IBOutlet weak var lblTypeRequired: UILabel!
    @IBOutlet weak var lblAddressRequired: UILabel!
    @IBOutlet weak var imgImage: UIImageView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    var bIsTitleValid: Bool = false
    var bIsAmountValid: Bool = false
    var bIsPriceValid: Bool = false
    var bIsTypeValid: Bool = false
    var bIsAddressValid: Bool = false
    var selectedEventTypeId: Int = 1
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var autocompleteController = GMSAutocompleteViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        self.btnSave.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Lato-bold", size: 20.0)], for: .normal)
        self.btnSave.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Lato-bold", size: 20.0), NSForegroundColorAttributeName: UIColor(white: 0.85, alpha: 0.8)], for: .disabled)
        txtPrice.keyboardType = UIKeyboardType.numberPad
        txtAmount.keyboardType = UIKeyboardType.numberPad
        self.loadingSpinner.isHidden = true
        
        self.txtTitle.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        self.txtAmount.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        self.txtPrice.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        self.txtEventAddress.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        self.txtEventType.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        
        self.txtPrice.delegate = self
        self.txtAmount.delegate = self
        autocompleteController.delegate = self
        autocompleteController.tableCellBackgroundColor = .lightGray
                
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    // Validate that amount&price fields contains only numbers and greater than 0
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == self.txtAmount || textField == self.txtPrice) {
            // Check if the input string contains only numbers
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
        
            var bIsStartWithZero: Bool = false
        
            // Check if the field start with zero
            if (textField.text == "" && string == "0") {
                bIsStartWithZero = true
            }
        
            return (string == numberFiltered) && !bIsStartWithZero
        }
        
        return true
    }
    
    func textFieldDidChanged(_ textField: UITextField) {
        switch textField {
        case txtTitle:
            isFieldNotEmpty(textField: self.txtTitle, validteBool: &bIsTitleValid, requiredLabel: self.lblTitleRequired)
            break
        case txtAmount:
            isFieldNotEmpty(textField: self.txtAmount, validteBool: &bIsAmountValid, requiredLabel: self.lblAmountRequired)
            break
        case txtPrice:
            isFieldNotEmpty(textField: self.txtPrice, validteBool: &bIsPriceValid, requiredLabel: self.lblPriceRequired)
            break
        case txtEventAddress:
            isFieldNotEmpty(textField: self.txtEventAddress, validteBool: &bIsAddressValid, requiredLabel: self.lblAddressRequired)
            break
        case txtEventType:
            isFieldNotEmpty(textField: self.txtEventType, validteBool: &bIsTypeValid, requiredLabel: self.lblTypeRequired)
            break
            
        default:
            break
        }
        
        if (bIsTitleValid && bIsAmountValid && bIsPriceValid && bIsAddressValid && bIsTypeValid) {
            self.btnSave.isEnabled = true
        } else {
            self.btnSave.isEnabled = false
        }
    }
    
    func isFieldNotEmpty(textField: UITextField, validteBool: inout Bool, requiredLabel: UILabel) {
        if (textField.text != "") {
            validteBool = true
            requiredLabel.isHidden = true
        } else {
            validteBool = false
            requiredLabel.isHidden = false
        }
    }
    
    @IBAction func AddressTouched(_ sender: Any) {
        present(self.autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func AddressTypingStarted(_ sender: Any) {
        present(self.autocompleteController, animated: true, completion: nil)
    }
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.txtEventAddress.text = place.name
        self.latitude = place.coordinate.latitude
        self.longitude = place.coordinate.longitude
        dismiss(animated: true, completion: nil)
        textFieldDidChanged(self.txtEventAddress)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func saveTicket(_ sender: Any) {
        self.loadingSpinner.isHidden = false
        self.loadingSpinner.startAnimating()
        
        if self.imgImage.image != nil {
            Model.instance.saveImage(image: self.imgImage.image!, name: self.txtTitle.text!) {(url) in
                let ticket = Ticket(seller: Model.instance.getCurrentAuthUserUID()!, title: self.txtTitle.text!, price: Double(self.txtPrice.text!)!, amount: Int(self.txtAmount.text!)!, eventType: self.selectedEventTypeId, address: self.txtEventAddress.text!, isSold: false, description: self.txtDescription.text!, imageUrl: url, latitude: self.latitude, longitude: self.longitude)
                Model.instance.addTicket(ticket: ticket)
                
                self.loadingSpinner.stopAnimating()
                self.loadingSpinner.isHidden = true
                
                self.navigationController!.popViewController(animated: true)
            }
        } else {
            let ticket = Ticket(seller: Model.instance.getCurrentAuthUserUID()!, title: txtTitle.text!, price: Double(txtPrice.text!)!, amount: Int(txtAmount.text!)!, eventType: 1, address: txtEventAddress.text!, isSold: false, description: txtDescription.text, imageUrl: nil, latitude: self.latitude, longitude: self.longitude)
            Model.instance.addTicket(ticket: ticket)
            
            self.loadingSpinner.stopAnimating()
            self.loadingSpinner.isHidden = true
            
            self.navigationController!.popViewController(animated: true)
        }
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
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return Model.eventTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return Model.eventTypes[row].displayName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.txtEventType.text = Model.eventTypes[row].displayName
        textFieldDidChanged(self.txtEventType)
        self.selectedEventTypeId = Model.eventTypes[row].id
        self.dropdownEventType.isHidden = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txtEventType {
            self.dropdownEventType.isHidden = false
            //if you dont want the users to se the keyboard type:
            textField.endEditing(true)
        } else {
            self.dropdownEventType.isHidden = true
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
