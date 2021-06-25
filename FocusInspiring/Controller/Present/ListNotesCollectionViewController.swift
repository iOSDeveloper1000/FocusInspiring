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

class ListNotesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, Emptiable {

    // MARK: Properties

    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<InspirationItem>!

    var backgroundLabel: UILabel?


    // MARK: Outlets

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: CollectionViewFlowLayout!


    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFetchedResultsController()

        collectionView.delegate = self
        collectionView.dataSource = self

        let layoutParam = LayoutParameter.ListNotesCollectionView.self
        flowLayout.setLayoutParameters(lineSpacing: layoutParam.lineSpacing, interitemSpacing: layoutParam.interitemSpacing, itemsPerRowPortrait: layoutParam.itemsPerRowPortrait, itemsPerRowLandscape: layoutParam.itemsPerRowLandscape)

        collectionView.collectionViewLayout = flowLayout
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpFetchedResultsController()

        collectionView.reloadData()
        flowLayout?.invalidateLayout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        fetchedResultsController = nil
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        flowLayout?.invalidateLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateEmptyViewLayout()
    }


    // MARK: Setup

    private func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<InspirationItem> = InspirationItem.fetchRequest()

        /// Fetch all inactive items, means being in List of Glory
        fetchRequest.predicate = NSPredicate(format: "active == FALSE")

        let sortDescriptor = NSSortDescriptor(key: "presentingDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "inspirationSuccessList")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            // @todo INFORM USER WITH A POP-UP
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }


    // MARK: Data Source & Delegation

    func numberOfSections(in collectionView: UICollectionView) -> Int {

        return fetchedResultsController.sections?.count ?? 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        let count = fetchedResultsController.sections?[section].numberOfObjects ?? 0

        /// Show or hide a background label that appears when list is empty
        let emptyLabel = EmptyViewLabel.ListNotesCollectionView.self
        (count < 1) ? setEmptyViewLabel(title: emptyLabel.title, message: emptyLabel.message) : removeEmptyViewLabel()

        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.inspirationalNoteCell, for: indexPath) as! InspirationalNoteCell

        let note = fetchedResultsController.object(at: indexPath)

        /// Equip cell with label and (default) image
        cell.subtitle.text = (note.title ?? "").isEmpty ? "<no title>" : note.title

        if let img = note.image {
            cell.imageView.image = UIImage(data: img)
        } else {
            cell.imageView.image = UIImage(systemName: "photo")
        }

        cell.layoutIfNeeded()

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        /// Instantiate and push viewcontroller for presenting note in detail mode
        let detailNoteVC = self.storyboard?.instantiateViewController(identifier: ReuseIdentifier.detailNoteViewController) as! DetailNoteViewController

        detailNoteVC.dataController = dataController
        detailNoteVC.note = fetchedResultsController.object(at: indexPath)
        navigationController?.pushViewController(detailNoteVC, animated: true)
    }

    /*func collectionView(UICollectionView, contextMenuConfigurationForItemAt: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        // @opt-todo IMPLEMENT CONTEXT MENU
    }*/
}
