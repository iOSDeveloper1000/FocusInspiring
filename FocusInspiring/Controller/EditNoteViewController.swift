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

    // MARK: Outlets

    @IBOutlet weak var titleField: CustomTextField!
    @IBOutlet weak var textView: CustomTextView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var imageButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!


    // MARK: Properties

    /// Temporary note holding all edits - calling view controller reads from this object afterwards if user saves his edit
    var temporaryNote: TemporaryDataItem!

    /// Pass back result of editing with state confirmed (--> 'Done') or canceled
    var completion: ((_ editConfirmed: Bool, _ edit: TemporaryDataItem?) -> Void)?


    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpToolbar()

        /// Load temporary note into view
        setUpNoteForEdit()
    }


    // MARK: Actions

    @IBAction func imageButtonPressed(_ sender: Any) {
        pickImage(sourceType: .photoLibrary)
    }

    @IBAction func cameraButtonPressed(_ sender: Any) {
        pickImage(sourceType: .camera)
    }

    /// For searchButton action see segue preparation below


    @IBAction func cancelButtonPressed(_ sender: Any) {
        /// Cancel view controller without saving any edit
        completion?(false, nil)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        /// Return to calling view controller with edit transfered
        completion?(true, temporaryNote)
        dismiss(animated: true, completion: nil)
    }


    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToFlickrSearch" {
            let navigationController = segue.destination as! UINavigationController
            let flickrController = navigationController.topViewController as! FlickrSearchCollectionViewController

            flickrController.returnImage = { imgData in

                self.imageView.image = UIImage(data: imgData)

                self.temporaryNote.image = imgData
            }
        }
    }


    // MARK: Setup

    /// Fill in content into the view controller's fields for edit
    private func setUpNoteForEdit() {
        guard let temporaryNote = temporaryNote else {
            popupAlert(title: "Internal error", message: "Could not load the note for editing.", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [cancelAlertHandler(alertAction:)])
            return
        }

        titleField.setUpCustomTextField(with: temporaryNote.title, saveRoutine: { titleString in
            self.temporaryNote.title = titleString
        })

        textView.setUpCustomTextView(with: temporaryNote.attributedText, saveRoutine: { attributedString in
            self.temporaryNote.attributedText = attributedString
        })

        if let imgData = temporaryNote.image {
            imageView.image = UIImage(data: imgData)
        } else {
            imageView.image = nil
        }
    }

    /// Set up toolbar elements
    private func setUpToolbar() {
        imageButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }


    // MARK: Helper

    private func pickImage(sourceType: UIImagePickerController.SourceType) {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType

        present(imagePicker, animated: true, completion: nil)
    }


    // MARK: Handler

    func cancelAlertHandler(alertAction: UIAlertAction) {
        /// Cancel view controller without any edit
        completion?(false, nil)
        dismiss(animated: true, completion: nil)
    }
}


// MARK: UIImagePickerController Delegation

extension EditNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            imageView.image = uiImage

            /// Save image data into temporary note
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