//
//  ListNotesCollectionViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 25.06.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit
import CoreData


// MARK: ListNotesCollectionViewController: UIViewController

class ListNotesCollectionViewController: UIViewController {

    // MARK: - Properties

    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<InspirationItem>!

    /**
     Background view with a hint that the chosen collection view section is empty.
     */
    private var emptyViewLabel: BackgroundLabel?

    private var successNotesSectionIndex: Int? // Section index of successful terminated notes in FRC
    private var activeNotesSectionIndex: Int? // Section index of ongoing active notes in FRC


    // MARK: - Outlets

    @IBOutlet weak var listControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: CollectionViewFlowLayout!

    @IBOutlet weak var collectionViewTopLayoutConstraint: NSLayoutConstraint!


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFetchedResultsController()

        // @todo REFACTOR TO SEPARATE METHOD
        collectionView.delegate = self
        collectionView.dataSource = self

        let layoutParam = LayoutParameter.ListNotesCollectionView.self
        flowLayout.setLayoutParameters(lineSpacing: layoutParam.lineSpacing, interitemSpacing: layoutParam.interitemSpacing, itemsPerRowPortrait: layoutParam.itemsPerRowPortrait, itemsPerRowLandscape: layoutParam.itemsPerRowLandscape)

        collectionView.collectionViewLayout = flowLayout

        // Setup background label - message will be set in delegate method
        emptyViewLabel = addBackgroundLabel(message: Message(title: "", body: ""))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupFetchedResultsController()

        // Select Success List as default and primary view
        navigationItem.title = "list-notes-title-success"~
        listControl.selectedSegmentIndex = 0

        collectionView.reloadData()
        flowLayout?.invalidateLayout()

        listControl.isUserInteractionEnabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        listControl.isUserInteractionEnabled = false

        fetchedResultsController = nil
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Update layout only if this view controller is presented
        guard tabBarController?.selectedIndex == ViewControllerIdentifier.listNotesVC else { return }

        // Hide segmented control in landscape orientation
        let isOrientationPortrait = UIScreen.isDeviceOrientationPortrait(for: size)
        collectionViewTopLayoutConstraint?.constant = isOrientationPortrait ? 60 : 0
        listControl?.isHidden = !isOrientationPortrait

        flowLayout?.invalidateLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        emptyViewLabel?.centerInSuperview()
    }


    // MARK: - Action

    @IBAction func listControlIndexChanged(_ sender: Any) {

        // Disable change of segmented control selection during reload
        listControl.isUserInteractionEnabled = false

        navigationItem.title = (listControl.selectedSegmentIndex == 1) ? "list-notes-title-active"~ : "list-notes-title-success"~

        collectionView.reloadData()

        // Enable segmented control again
        listControl.isUserInteractionEnabled = true
    }


    // MARK: - Setup

    private func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<InspirationItem> = InspirationItem.fetchRequest()

        // No predicate used since all notes shall be loaded

        let sectionSortDescriptor = NSSortDescriptor(key: "active", ascending: true)
        let presentingSortDescriptor = NSSortDescriptor(key: "presentingDate", ascending: false)

        fetchRequest.sortDescriptors = [sectionSortDescriptor, presentingSortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: "active", cacheName: "listOfAllSavedNotes")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            // @todo INFORM USER WITH A POP-UP
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}


// MARK: - UICollectionView Data Source & Delegate

extension ListNotesCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let countSections = fetchedResultsController.sections?.count else { return 1 }

        let selectedSegment = listControl.selectedSegmentIndex

        // Message to be displayed or nil if none shall be presented
        var emptyViewMsg: Message? = (selectedSegment == 1) ? LabelText.EmptyView.activeNotesList : LabelText.EmptyView.successList

        // Reset section indices
        successNotesSectionIndex = nil // nil = empty section for success entries
        activeNotesSectionIndex = nil // nil = empty section for active entries

        switch countSections {
        case 0:
            // emptyViewMsg according to selected segment will be presented
            break

        case 1:
            let sectionValue = fetchedResultsController.sections?[0].name // Value for key 'active'
            let isActiveNotesSectionNonEmpty: Bool = (sectionValue == "1")

            // Set section index of displayed section
            isActiveNotesSectionNonEmpty ? (activeNotesSectionIndex = 0) : (successNotesSectionIndex = 0)

            if isActiveNotesSectionNonEmpty ^ (selectedSegment == 0) {
                emptyViewMsg = nil
            }

        case 2:
            // Successful notes as well as active notes are existing
            successNotesSectionIndex = 0
            activeNotesSectionIndex = 1

            // Remove empty view label
            emptyViewMsg = nil

        default:
            emptyViewMsg = nil
            track("UNKNOWN DEFAULT: More than two sections in FRC found")
            break
        }

        // Handle background message
        if let emptyViewMsg = emptyViewMsg {
            emptyViewLabel?.updateText(with: emptyViewMsg)
            emptyViewLabel?.isHidden = false
        } else {
            emptyViewLabel?.isHidden = true
        }

        return countSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        var count = fetchedResultsController.sections?[section].numberOfObjects ?? 0

        let selectedSection: Int? = (listControl.selectedSegmentIndex == 1) ? activeNotesSectionIndex : successNotesSectionIndex

        if selectedSection != section {
            // This section shall be hidden
            count = 0
        }

        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.forCollectionViewCell.inspirationalNote, for: indexPath) as! InspirationalNoteCell

        let note = fetchedResultsController.object(at: indexPath)

        // Active notes are shaded: then recognizable at once that not success notes are presented
        let shadeThisItem: Bool = note.active

        // Equip cell with label and (default) image
        cell.subtitle.text = (note.title ?? "").isEmpty ? "label-empty-title"~ : note.title
        cell.subtitle.textColor = shadeThisItem ? LayoutParameter.TextColor.placeholder : LayoutParameter.TextColor.standard

        if let img = note.image {
            cell.imageView.image = UIImage(data: img)
        } else {
            cell.imageView.image = UIImage(systemName: "photo")
        }

        cell.imageView.backgroundColor = shadeThisItem ? UIColor.gray : UIColor.clear

        cell.layoutIfNeeded()

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // Instantiate and push viewcontroller for presenting note in detail
        let detailNoteVC = self.storyboard?.instantiateViewController(identifier: ReuseIdentifier.forViewController.detailNote) as! DetailNoteViewController

        detailNoteVC.dataController = dataController
        detailNoteVC.note = fetchedResultsController.object(at: indexPath)
        navigationController?.pushViewController(detailNoteVC, animated: true)
    }

    /*func collectionView(UICollectionView, contextMenuConfigurationForItemAt: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        // @opt-todo IMPLEMENT CONTEXT MENU
    }*/
}


// MARK: - NSFetchedResultsController Delegate

extension ListNotesCollectionViewController: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Empty body -- from the Documentation:
        //     "A delegate must implement at least one of the change tracking delegate methods in order for change tracking to be enabled. Providing an empty implementation of controllerDidChangeContent(_:) is sufficient."
    }
}
