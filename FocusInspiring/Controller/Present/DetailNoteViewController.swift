//
//  DetailNoteViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 23.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: DetailNoteViewController: UIViewController

class DetailNoteViewController: UIViewController {

    // MARK: - Properties

    var note: InspirationItem?

    var dataController: DataController?


    // MARK: - Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creatingDateLabel: UILabel!
    @IBOutlet weak var presentingDateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var contentStackView: UIStackView!

    @IBOutlet weak var deleteButton: UIBarButtonItem!


    // MARK: - Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateNoteOnScreen()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Change to horizontal axis in landscape orientation
        contentStackView.axis = UIScreen.isDeviceOrientationPortrait() ? .vertical : .horizontal
    }


    // MARK: - Action

    @IBAction func deleteButtonPressed(_ sender: Any) {
        guard note != nil else {
            // @todo AVOID CRASH WHEN ERROR OCCURS
            fatalError("Note for deletion not found")
        }

        popupAlert(title: "alert-title-delete-complete-note"~, message: "", alertStyle: .alert, actionTitles: ["action-delete-confirm"~, "action-cancel"~], actionStyles: [.destructive, .cancel], actions: [deleteHandler(alertAction:), nil])
    }


    // MARK: - Handler

    func deleteHandler(alertAction: UIAlertAction) {

        // @todo DELETE ALSO NOTIFICATION

        dataController?.viewContext.delete(note!)
        dataController?.saveViewContext()

        navigationController?.popViewController(animated: true)
    }


    // MARK: - Helper

    /**
     Updates UI elements with content of the note.
     */
    private func updateNoteOnScreen() {
        guard  let note = note else { return }

        // Header part

        let creatingDateStr: String
        let presentingDateStr: String

        if let creatingDate = note.creationDate {
            creatingDateStr = DateFormatting.headerFormat.string(from: creatingDate)
        } else {
            creatingDateStr = "???"
        }
        if let presentingDate = note.presentingDate {
            presentingDateStr = DateFormatting.headerFormat.string(from: presentingDate)
        } else {
            presentingDateStr = "???"
        }

        titleLabel.text = note.title
        creatingDateLabel.text = "label-note-creation-date"~creatingDateStr
        presentingDateLabel.text = "label-note-presenting-date"~presentingDateStr


        // Main part

        if let imgData = note.image {
            imageView.isHidden = false
            imageView.image = UIImage(data: imgData)
        } else {
            imageView.isHidden = true
            imageView.image = nil
        }

        textView.attributedText = note.attributedText
    }
}
