//
//  DetailNoteViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 23.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit

class DetailNoteViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var presentingDateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var contentStackView: UIStackView!

    @IBOutlet weak var deleteButton: UIBarButtonItem!


    // MARK: Properties

    var note: InspirationItem?

    var dataController: DataController?

    /// Date formatter for the displayed dates
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()


    // MARK: Life cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateNoteOnScreen()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        /// Change to horizontal axis in landscape orientation
        contentStackView.axis = UIScreen.isDeviceOrientationPortrait() ? .vertical : .horizontal
    }


    // MARK: Action

    @IBAction func deleteButtonPressed(_ sender: Any) {
        guard  note != nil else {
            fatalError("Note for deletion not found")
        }

        popupAlert(title: "Do you really want to delete your note of success permanently?", message: "", alertStyle: .alert, actionTitles: ["Delete", "Cancel"], actionStyles: [.destructive, .cancel], actions: [deleteHandler(alertAction:), nil])
    }


    // MARK: Helper

    /// Fill in content into the view elements
    private func updateNoteOnScreen() {
        guard  let note = note else {
            track("GUARD FAILED: Note not found")
            return
        }

        titleLabel.text = note.title
        creationDateLabel.text = "Created: \(dateFormatter.string(from: note.creationDate!))"
        presentingDateLabel.text = "Displayed: \(dateFormatter.string(from: note.presentingDate!))"
        if let imgData = note.image {
            imageView.image = UIImage(data: imgData)
        } else {
            imageView.image = nil
        }
        textView.attributedText = note.attributedText
    }


    // MARK: Handler

    func deleteHandler(alertAction: UIAlertAction) {
        /// Delete displayed note
        dataController?.viewContext.delete(note!)
        dataController?.saveViewContext()

        navigationController?.popViewController(animated: true)
    }
}
