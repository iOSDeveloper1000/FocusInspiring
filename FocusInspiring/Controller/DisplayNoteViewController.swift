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
    
    @IBOutlet weak var successfullyIntegratedButton: UIBarButtonItem!
    @IBOutlet weak var displayAgainButton: UIBarButtonItem!
    @IBOutlet weak var deleteArchiveButton: UIBarButtonItem!
    
    
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
    
    @IBAction func successFullyIntegratedPressed(_ sender: Any) {
        handleIntegratedItem()
    }
    
    @IBAction func displayAgainPressed(_ sender: Any) {
        
    }
    
    @IBAction func deleteArchivePressed(_ sender: Any) {
        
    }
    
    
    // MARK: Setup and View
    
    private func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<InspirationItem> = InspirationItem.fetchRequest()
        
        /* Get all items dated for today or earlier */
        let current = Date()
        fetchRequest.predicate = NSPredicate(format: "active == TRUE AND presentingDate <= %@", current as CVarArg)
        
        let sortDescriptor = NSSortDescriptor(key: "presentingDate", ascending: true)
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
    
    private func displayNextItem() {
        
        if fetchedItems.isEmpty {
            print("No item found")
            
            setBackgroundMessage(message: "No more inspirational notes to display this time.\n\nFeel lucky! :-)")
            hideUIElements(true)
        } else {
            displayedItem = fetchedItems.popLast()
            
            // Fill in content into the view fields
            titleLabel.text = displayedItem.text
            creationDateLabel.text = "Created on \(dateFormatter.string(from: displayedItem.creationDate!))"
            presentingDateLabel.text = "Displayed on \(dateFormatter.string(from: displayedItem.presentingDate!))"
            if let imgData = displayedItem.image {
                imageView.image = UIImage(data: imgData)
            }
            textView.text = displayedItem.text
        }
    }
    
    
    // MARK: Handling displayed items
    
    private func handleIntegratedItem() {
        let alertController = UIAlertController(title: "Congratulations!", message: "Press OK to confirm adding this note to the List of Glory. Cancel otherwise.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.displayedItem.active = false
            self.dataController.saveViewContext()
            
            self.displayNextItem()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true)
    }
    
}


// MARK: Background messages

extension DisplayNoteViewController {
    
    func setBackgroundMessage(message: String) {
        backgroundLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        backgroundLabel.text = message
        backgroundLabel.textAlignment = .center
        backgroundLabel.textColor = .gray
        
        view.addSubview(backgroundLabel)
    }
    
    func removeBackgroundMessage() {
        view.willRemoveSubview(backgroundLabel)
        backgroundLabel = nil
    }
    
    func hideUIElements(_ hide: Bool) {
        titleLabel.isHidden = hide
        creationDateLabel.isHidden = hide
        presentingDateLabel.isHidden = hide
        imageView.isHidden = hide
        textView.isHidden = hide
    }
}

