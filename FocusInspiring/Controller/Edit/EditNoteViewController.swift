//
//  EditNoteViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 15.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: EditNoteViewController: UIViewController

class EditNoteViewController: UIViewController {

    // MARK: - Properties

    /**
     Note item holding current edit.
     */
    var temporaryNote: TemporaryDataItem!

    /**
     Completion handler for returning edited note.

     Confirm flag set to _true_ when user taps _Done_, _false_ when canceled.
     */
    var completion: ((_ editConfirmed: Bool, _ edit: TemporaryDataItem?) -> Void)?


    // MARK: - Outlets

    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var titleField: EditableTextField!
    @IBOutlet weak var textView: EditableTextView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var imageButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupToolbar()

        // Load temporary note into view
        loadNoteOnScreen()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Change to horizontal axis in landscape orientation
        contentStackView.axis = UIScreen.isDeviceOrientationPortrait() ? .vertical : .horizontal
    }


    // MARK: - Actions

    @IBAction func imageButtonPressed(_ sender: UIBarButtonItem) {
        replaceImage(sourceType: .photoLibrary)
    }

    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        replaceImage(sourceType: .camera)
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        // Cancel view controller without saving any edit
        completion?(false, nil)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        // Return to calling view controller with edit transfered
        completion?(true, temporaryNote)
        dismiss(animated: true, completion: nil)
    }


    // MARK: - Helpers

    func cancelAlertHandler(alertAction: UIAlertAction) {
        // Cancel view controller without any edit
        completion?(false, nil)
        dismiss(animated: true, completion: nil)
    }


    /**
     Setup method for toolbar items.
     */
    private func setupToolbar() {
        imageButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    /**
     Fill in content into view controller's fields for editing.
     */
    private func loadNoteOnScreen() {
        guard let temporaryNote = temporaryNote else {
            popupAlert(title: "Internal error", message: "Could not load the note for editing.", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [cancelAlertHandler(alertAction:)])
            return
        }

        titleField.setUpCustomTextField(with: temporaryNote.title, saveRoutine: { titleString in
            self.temporaryNote.title = titleString
        })

        textView.setup(with: temporaryNote.attributedText, saveRoutine: { attributedString in
            self.temporaryNote.attributedText = attributedString
        })

        if let imgData = temporaryNote.image {
            imageView.isHidden = false
            imageView.image = UIImage(data: imgData)
        } else {
            imageView.isHidden = true
            imageView.image = nil
        }
    }

    private func replaceImage(sourceType: UIImagePickerController.SourceType) {

        if imageView.image != nil {
            popupAlert(title: "New image will overwrite former one", message: "Are you sure you want to pick a new image overwriting the currently chosen one?", alertStyle: .alert, actionTitles: ["Overwrite", "Cancel"], actionStyles: [.destructive, .cancel], actions: [{ _ in self.pickNewImage(sourceType: sourceType) }, nil]
            )
        } else {
            pickNewImage(sourceType: sourceType)
        }
    }

    /**
     Present image picker controller.
     */
    private func pickNewImage(sourceType: UIImagePickerController.SourceType) {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType

        present(imagePicker, animated: true, completion: nil)
    }
}


// MARK: - UIImagePickerController Delegate

extension EditNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            imageView.isHidden = false
            imageView.image = uiImage

            // Save image to a temporary note
            temporaryNote.image = uiImage.jpegData(compressionQuality: 0.98)

        } else {
            popupAlert(title: "Image not found", message: "The selected image cannot be loaded into the app.", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [nil])
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
