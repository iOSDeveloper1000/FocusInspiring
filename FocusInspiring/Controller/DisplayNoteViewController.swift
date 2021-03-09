//
//  DisplayNoteViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 23.02.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit
import CoreData


// MARK: DisplayNoteViewController: UIViewController, NSFetchedResultsControllerDelegate

class DisplayNoteViewController: UIViewController, NSFetchedResultsControllerDelegate {

    // MARK: Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var presentingDateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var checkmarkButton: UIBarButtonItem!
    @IBOutlet weak var repeatButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!


    // MARK: Properties

    var displayedItem: InspirationItem!

    var fetchedItems: [InspirationItem] = []

    var dataController: DataController!

    var fetchedResultsController: NSFetchedResultsController<InspirationItem>!

    /* Date formatter for the displayed creation and presenting date */
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    // Label for displaying a message in case no more items are available
    var backgroundLabel: UILabel!


    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFetchedResultsController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupFetchedResultsController()

        // Display first inspirational note
        displayNextItem()

        setUpViewLayout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        fetchedResultsController = nil
    }


    // MARK: Actions

    @IBAction func checkmarkButtonPressed(_ sender: Any) {
        popupAlert(title: "Congratulations!", message: "Confirming adds the note to the List of Glory.", alertStyle: .alert, actionTitles: ["Cancel", "OK"], actionStyles: [.cancel, .default], actions: [
                    { _ in },
                    { _ in
                        self.displayedItem.active = false
                        self.dataController.saveViewContext()

                        self.displayNextItem()
                    }
        ])
    }

    @IBAction func repeatButtonPressed(_ sender: Any) {
        // @todo implement repeat function
        print("Repeat button pressed")
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        // @todo implement edit function
        print("Edit button pressed")
    }

    @IBAction func deleteButtonPressed(_ sender: Any) {
        // @todo implement delete function
        print("Delete button pressed")
    }


    // MARK: Setup

    private func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<InspirationItem> = InspirationItem.fetchRequest()

        /* Get all items dated for today or earlier */
        let current = Date()
        fetchRequest.predicate = NSPredicate(format: "active == TRUE AND presentingDate <= %@", current as CVarArg)

        let sortDescriptor = NSSortDescriptor(key: "presentingDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "inspirationItems")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            fetchedItems = fetchedResultsController.fetchedObjects ?? []
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    private func setUpViewLayout() {
        textView.isUserInteractionEnabled = false
    }


    // MARK: Core functionality

    private func displayNextItem() {

        let isItemAvailable = !fetchedItems.isEmpty

        // Set user interface
        hideUIElements(!isItemAvailable)
        enableNavigationBarItems(isItemAvailable)

        if isItemAvailable {

            displayedItem = fetchedItems.popLast()

            // Fill in content into the view fields
            titleLabel.text = displayedItem.title
            creationDateLabel.text = "Created on \(dateFormatter.string(from: displayedItem.creationDate!))"
            presentingDateLabel.text = "Displayed on \(dateFormatter.string(from: displayedItem.presentingDate!))"
            if let imgData = displayedItem.image {
                imageView.image = UIImage(data: imgData)
            } else {
                imageView.image = nil
            }
            textView.text = displayedItem.text

            removeBackgroundMessage()

        } else {
            print("No item found")

            setBackgroundMessage(message: "No more inspirational notes to display this time.\n\nFeel lucky anyway! :-)")
        }
    }
}


// MARK: User Interface

extension DisplayNoteViewController {

    func setBackgroundMessage(message: String) {
        backgroundLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        backgroundLabel.text = message
        backgroundLabel.textAlignment = .center
        backgroundLabel.textColor = .gray
        backgroundLabel.numberOfLines = 0 // Use as many lines as needed

        view.addSubview(backgroundLabel)
    }
    
    func removeBackgroundMessage() {
        if backgroundLabel != nil {
            backgroundLabel.removeFromSuperview()
            backgroundLabel = nil
        }
    }

    func hideUIElements(_ hide: Bool) {
        titleLabel.isHidden = hide
        creationDateLabel.isHidden = hide
        presentingDateLabel.isHidden = hide
        imageView.isHidden = hide
        textView.isHidden = hide
    }

    func enableNavigationBarItems(_ enable: Bool) {
        checkmarkButton.isEnabled = enable
        repeatButton.isEnabled = enable
        editButton.isEnabled = enable
        deleteButton.isEnabled = enable
    }
}

