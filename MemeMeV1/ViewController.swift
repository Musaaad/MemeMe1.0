//
//  ViewController.swift
//  MemeMeV1
//
//  Created by Musaad on 9/25/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePicker: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var NavBar: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.contentMode = .scaleAspectFit //image should be aspect fit
        shareButton.isEnabled = false//disabled until an image is chosen
        
        textFieldsSettings(tf: topText, text: "TOP")
        textFieldsSettings(tf: bottomText, text: "BOTTOM")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)//check if camera is available
        subscribeToKeyboardNotifications()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func textFieldsSettings (tf: UITextField, text: String) {
        
        let _: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 35)!,
            NSAttributedString.Key.strokeWidth:  -3.0
        ]
        
        tf.textColor = UIColor.white
        tf.tintColor = UIColor.white
        tf.textAlignment = .center
        tf.text = text
        tf.delegate = self
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM"{
            textField.text = ""
        }
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() //When done is clicked, it will hide the keyboard
        return true
    }
    
    //picking an image from the photo library
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        
        chooseImageFromCameraOrPhoto(source: .photoLibrary)
        
    }
    
    
    //to make the camera available
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .camera)
    }
    
      func chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    
    //picking an image from the library and showing it
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    
    {
        
        if let image = info[.originalImage] as? UIImage {
            imagePicker.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    //When the keyboardWillShow notification is received, shift the view's frame up
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomText.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    
    
    //this will hide the keyboard
    func keyboardWillHide(_ notification:Notification) {
        if bottomText.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    
    
    
    //a share button to share the image
    @IBAction func shareButton(_ sender: Any) {
        
        let memedImage = generateMemedImage()
        let activityView = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityView.completionWithItemsHandler = {(activity, completed, items, error) in
            if (completed) {
                let _ = self.save()
            }
        }
        
        self.present(activityView, animated: true, completion: nil)
        
    }
    
    //a button to cancel everything
    @IBAction func cancelButton(_ sender: Any) {
        
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        imagePicker.image = nil
        shareButton.isEnabled = false
    }
    
    
    
    //When the keyboardWillShow notification is received, shift the view's frame up
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    
    //save the meme image
    func save() {
         let memedImage = generateMemedImage()
        
        // Create the meme
        _ = Meme(topText: topText.text!, bottomText: bottomText.text!, image: imagePicker.image!, memedImage: memedImage)
    }
    
    //generate the meme image by combining the original img with the text
    func generateMemedImage() -> UIImage {
        
        bottomToolBar.isHidden = true
        NavBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        bottomToolBar.isHidden = false
        NavBar.isHidden = false
        
        return memedImage
    }
    
    

        
    }


