//
//  ViewController.swift
//  Lets meme
//
//  Created by Ankita Satpathy on 03/06/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import UIKit

class MemeEditViewController: UIViewController ,  UINavigationControllerDelegate  {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var camBtn: UIBarButtonItem!
    
    @IBOutlet weak var topTF: UITextField!
    @IBOutlet weak var bottomTF: UITextField!
    
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    
    let memeTextAttributes:[String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 35)!,
        NSAttributedStringKey.strokeWidth.rawValue: -2.5]
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
       camBtn.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        configureTextField(textField: topTF, withText: "TOP")
        configureTextField(textField: bottomTF, withText: "BOTTOM")
    }
    
    func configureTextField(textField: UITextField, withText: String) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = withText
        textField.delegate = self
        textField.textAlignment = .center
        
    }
    
    @IBAction func albumTapped(_ sender: Any) {
        chooseSourceType(sourceType: .photoLibrary)
    }
    

    @IBAction func cameraBtntapped(_ sender: Any) {
        chooseSourceType(sourceType: .camera)

    }

    @IBAction func cancelTapped(_ sender: Any) {
        shareBtn.isEnabled = false
        topTF.text = "TOP"
        bottomTF.text = "BOTTOM"
        imageview.image = nil
    }
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_ :)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
   
    
    
    func generateMemedImage() -> UIImage {
        
        configureToolandNavBar(status: true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        configureToolandNavBar(status: false)
        return memedImage
    }
    
    func configureToolandNavBar(status: Bool){
        self.navBar.isHidden = status
        self.toolBar.isHidden =  status

    }

    func saveMemedImage(memedImage: UIImage) {
        // Create the meme
        let meme = Meme(topText: topTF.text!, bottomText: bottomTF.text!, originalImage: imageview.image!, memedImage: memedImage)
        
        // Add it to the memes array in the Application Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
        print("meme Saved, memes count" + "\(appDelegate.memes.count)")
    }
    
    @IBAction func shareBtnTapped(_ sender: Any) {
        let memedImage = generateMemedImage()
        let shareController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        present(shareController, animated: true, completion: nil)
        shareController.completionWithItemsHandler = {
            activity , success, items, error in
            if (!success){
                return
            }
            else {
                self.saveMemedImage(memedImage: memedImage)
            }
           self.dismiss(animated: true, completion: nil)
        }
            
    
    
    }
   
    
    //When the keyboardWillShow notification is received, shift the view's frame up
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTF.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomTF.isFirstResponder{
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

    
   }


//MARK: IMAGE PICKER METHODS

extension MemeEditViewController: UIImagePickerControllerDelegate {
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageview.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }

    
    func  chooseSourceType(sourceType: UIImagePickerControllerSourceType)  {
        let picker = UIImagePickerController()
        picker.delegate = self 
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)
        
    }
    
}

 //MARK: TEXTFIELD METHODS

extension MemeEditViewController: UITextFieldDelegate {
   
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
}



