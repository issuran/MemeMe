//
//  ViewController.swift
//  MemeMe v1 
//
//  Created by Tiago Oliveira on 24/11/18.
//  Copyright © 2018 Optimize 7. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController {
    
    // MARK: Variables
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var memeTextAttributes: [NSAttributedString.Key: Any]?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareButton.isEnabled = false
        
        setStyle(toTextField: topTextField)
        setStyle(toTextField: bottomTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeObservers()
    }
    
    // MARK: Actions
    @IBAction func getImageFromAlbum(_ sender: Any) {
        displayPickerImage(source: .photoLibrary)
    }
    
    @IBAction func getImageFromCamera(_ sender: Any) {
        displayPickerImage(source: .camera)
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        save()
    }
    
    @IBAction func cancelMeme(_ sender: Any) {
        memeImageView.image = #imageLiteral(resourceName: "Empty")
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        shareButton.isEnabled = false
    }
    
    // MARK: Private methods
    private func subscribeObservers() {
        observeKeyboardWillAppear()
        observeKeyboardWillDisappear()
        observeTapDismiss()
    }
    
    private func unsubscribeObservers() {
        undoObserveKeyboardWillAppear()
        undoObserveKeyboardWillDisappear()
    }
    
    private func setStyle(toTextField textField: UITextField) {
        textField.defaultTextAttributes = textAttributesValues()
        textField.textAlignment = .center
        textField.autocapitalizationType = .allCharacters
        textField.delegate = self
    }
    
    private func textAttributesValues() -> [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -2
        ]
    }
    
    private func displayPickerImage(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = source
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }
    
    private func save() {
        
        let memedImage = generateMemedImage()
        
//        let meme = Meme(
//            topText: topTextField.text ?? "",
//            bottomText: bottomTextField.text ?? "",
//            image: memeImageView.image!,
//            memeImage: memedImage)
        
        let meme = [memedImage]
        
        let activityViewController = UIActivityViewController(activityItems: meme, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func hideToolbars(_ hide: Bool) {
        topToolBar.isHidden = hide
        bottomToolBar.isHidden = hide
    }
    
    private func generateMemedImage() -> UIImage {
        
        hideToolbars(true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideToolbars(false)
        
        return memedImage
    }
    
    private func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        if let keyboardFrame: NSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            return keyboardFrame.cgRectValue.height
        }
        return 0
    }
    
    // MARK: Set Observer
    func observeKeyboardWillAppear() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
    }
    
    func observeKeyboardWillDisappear() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDisappear(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    func observeTapDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    // MARK: Subscribe actions
    @objc func keyboardWillShow(_ notification: Notification) {
        if (bottomTextField.isEditing) {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: Unsubscribe observers
    func undoObserveKeyboardWillAppear() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func undoObserveKeyboardWillDisappear() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension MemeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            memeImageView.image = image
            shareButton.isEnabled = true
        }
    }
}

extension MemeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
}
