//
//  AddNewNoteViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 23.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: AddNewNoteViewController: UIViewController

class AddNewNoteViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var selectImageButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var attachFileButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    // MARK: Properties
    
    var newItem: InspirationItem!
    
    var dataController: DataController!
    
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // @todo
        textView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // @todo fetch field entries from UserDefaults
        
        toggleUserInterface(enable: true)
        
        // unimplemented features disabled here @todo
        cameraButton.isEnabled = false
        attachFileButton.isEnabled = false
    }
    
    
    // MARK: Actions
    
    @IBAction func selectImageButtonPressed(_ sender: Any) {
        pickImage(sourceType: .photoLibrary)
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        pickImage(sourceType: .camera)
    }
    
    @IBAction func attachFileButtonPressed(_ sender: Any) {
        // @todo implement file attaching
        print("File attaching still to be implemented")
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        toggleUserInterface(enable: false)
        addNewItem()
    }
    
    
    // MARK: Helper
    
    private func addNewItem() {
        let newItem = InspirationItem(context: dataController.viewContext)
        newItem.active = true
        newItem.creationDate = Date()
        newItem.presentingDate = Date() // @todo alert controller for asking user
        newItem.title = titleTextField.text
        newItem.text = textView.text
        // @todo store images and file attachments
        
        dataController.saveViewContext()
    }
    
    private func toggleUserInterface(enable: Bool) {
        titleTextField.isEnabled = enable
        textView.isUserInteractionEnabled = enable
        selectImageButton.isEnabled = enable
        cameraButton.isEnabled = enable
        attachFileButton.isEnabled = enable
        saveButton.isEnabled = enable
    }
    
    private func pickImage(sourceType: UIImagePickerController.SourceType) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        
        present(imagePicker, animated: true, completion: nil)
    }
}


// MARK: UITextViewDelegate

extension AddNewNoteViewController: UITextViewDelegate {
    
    // @ todo implement delegate methods
}


// MARK: UIImagePickerControllerDelegate

extension AddNewNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imageView.image = image
            
        } else {
            // @todo error handling
            print("Image not found")
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
