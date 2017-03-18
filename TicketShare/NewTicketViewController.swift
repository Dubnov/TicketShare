//
//  NewTicketViewController.swift
//  TicketShare
//
//  Created by Chen g on 17/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class NewTicketViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtEventAddress: UITextField!
    @IBOutlet weak var lblTitleRequired: UILabel!
    @IBOutlet weak var lblAmountRequired: UILabel!
    @IBOutlet weak var lblPriceRequired: UILabel!
    @IBOutlet weak var lblAddressRequired: UILabel!
    @IBOutlet weak var imgImage: UIImageView!
    var bIsTitleValid: Bool = false
    var bIsAmountValid: Bool = false
    var bIsPriceValid: Bool = false
    var bIsAddressValid: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtPrice.keyboardType = UIKeyboardType.numberPad
        txtAmount.keyboardType = UIKeyboardType.numberPad
        
        self.txtTitle.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        self.txtAmount.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        self.txtPrice.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        self.txtEventAddress.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        
        self.txtPrice.delegate = self
        self.txtAmount.delegate = self
    }

    // Validate that amount&price fields contains only numbers
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
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
        default:
            break
        }
        
        if (bIsTitleValid && bIsAmountValid && bIsPriceValid && bIsAddressValid) {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func saveTicket(_ sender: Any) {
        if self.imgImage.image != nil {
            Model.instance.saveImage(image: self.imgImage.image!, name: self.txtTitle.text!) {(url) in
                let ticket = Ticket(seller: Model.instance.getCurrentAuthUserName()!, title: self.txtTitle.text!, price: Int(self.txtPrice.text!)!, amount: Int(self.txtAmount.text!)!, address: self.txtEventAddress.text!, description: self.txtDescription.text!, imageUrl: url)
                Model.instance.addTicket(ticket: ticket)
                self.navigationController!.popViewController(animated: true)
            }
        } else {
            let ticket = Ticket(seller: Model.instance.getCurrentAuthUserName()!, title: txtTitle.text!, price: Int(txtPrice.text!)!, amount: Int(txtAmount.text!)!, address: txtEventAddress.text!, description: txtDescription.text, imageUrl: nil)
            Model.instance.addTicket(ticket: ticket)
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
        }
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        self.imgImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismiss(animated: true, completion: nil);
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
