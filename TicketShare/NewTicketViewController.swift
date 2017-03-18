//
//  NewTicketViewController.swift
//  TicketShare
//
//  Created by Chen g on 17/03/2017.
//  Copyright © 2017 ios project. All rights reserved.
//

import UIKit

class NewTicketViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtEventAddress: UITextField!
    @IBOutlet weak var imgImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
