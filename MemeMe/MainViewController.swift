//
//  ViewController.swift
//  MemeMe
//
//  Created by Giray Gençaslan on 20.08.2018.
//  Copyright © 2018 Giray Gençaslan. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

// MARK: Meme Object

struct Meme {
    let topText : String
    let bottomText : String
    let originalImage : UIImage
    let memedImage : UIImage
    
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    var currentFont: UIFont = Fonts[0] as UIFont
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        
        AVCaptureDevice.requestAccess(for: .video) { (permission) in
            if permission {
                // Set camera button is enable
                self.albumButton.isEnabled = true
                
                // Pick image from camera (info.plist key added)
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                
                // Show alert
                let alert = UIAlertController(title: "Warning", message: "You can not use camera without giving permission", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        
        PHPhotoLibrary.requestAuthorization { (requestStatus) in
            
            if requestStatus == .authorized {
                
                // Pick image from album (info.plist key added)
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                
                // Show alert
                let alert = UIAlertController(title: "Warning", message: "You can not use photo library without giving permission", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func shareImage(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        // Run after activity view controller completed work
        activityViewController.completionWithItemsHandler = { (_, successful, _, _) in
            if successful {
                self.save(memedImage)
                self.shareButton.isEnabled = false
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        present(activityViewController, animated: true, completion: nil)   
    }
    
    @IBAction func cancel(_ sender: Any) {
        normalizeView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change navigation bar title color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.blue]
        
        // Set delegate to text fields (for running textfield delegate methods)
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        normalizeView()
        setTextAttributes()
        
        // Subscribe font changing
        NotificationCenter.default.addObserver(self, selector: #selector(self.setFont(notification:)), name: NSNotification.Name("FontChanging"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    @objc func setFont(notification: Notification) {
        
        // Set current font from posted notification
        let userInfo = notification.userInfo
        let font = userInfo!["Font"] as! UIFont
        self.currentFont = font
        
        print("Selected font is: \(font.familyName)")
        
        // Refresh text field font style
        setTextAttributes()
    }
    
    func normalizeView() {
        
        // Set share button enable to false
        shareButton.isEnabled = false
        
        // Reset image view
        imagePickerView.image = nil
        
        // Set title to text fields
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
    
    func setTextAttributes() {
        
        // Set text properties to text fields and
        let textAttributes: [String: Any] = [
            NSAttributedStringKey.strokeColor.rawValue      : UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue  : UIColor.white,
            NSAttributedStringKey.font.rawValue             : currentFont,
            NSAttributedStringKey.strokeWidth.rawValue      : -5
        ]
        topTextField.defaultTextAttributes = textAttributes
        bottomTextField.defaultTextAttributes = textAttributes
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // Set sharer button is enable
            shareButton.isEnabled = true
            
            // Set image view's image
            imagePickerView.image = image
            dismiss(animated: true, completion: nil)
        }
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide navbar and toolbar
        navigationController?.navigationBar.isHidden = true
        bottomToolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show navbar and toolbar
        navigationController?.navigationBar.isHidden = false
        bottomToolbar.isHidden = false
        
        return memedImage
    }
    
    func save(_ memedImage: UIImage) {
        let _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFontViewController" {
            let destinationScene = segue.destination as! FontViewController
            destinationScene.currentFont = self.currentFont
        }
    }
}

extension MainViewController {
    
    // MARK: Text Field Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
        
        if textField == bottomTextField { subscribeToKeyboardNotifications() }
        else { unsubscribeFromKeyboardNotifications() }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text=="" {
            if textField == topTextField { textField.text = "TOP" }
            else if textField == bottomTextField { textField.text = "BOTTOM" }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Keyboard Notification (& Support) Methods
    
    @objc func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y = -getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        guard let userInfo  = notification.userInfo else { return 0 }
        guard let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return 0 }
        return keyboardSize.cgRectValue.height
    }
}

