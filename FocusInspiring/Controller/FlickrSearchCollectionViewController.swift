//
//  FlickrSearchCollectionViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 12.03.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit


// MARK: FlickrSearchCollectionViewController: UICollectionViewController

class FlickrSearchCollectionViewController: UICollectionViewController {

    // MARK: Outlets

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!


    // MARK: Properties

    var returnImage: ((Data) -> Void)?

    private let reuseIdentifier = "FlickrSearchIdentifier"

    private struct LayoutConstant {
        static let spacing: CGFloat = 3
        static let itemsPerRowPortrait: CGFloat = 3
        static let itemsPerRowLandscape: CGFloat = 5
    }

    private struct SearchResult {
        var isPending: Bool = true
        let data: Data?
    }

    private var searchResults: [SearchResult] = []


    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        searchField.delegate = self

        collectionView.backgroundColor = .systemOrange
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        flowLayout?.invalidateLayout()
    }


    // MARK: Actions

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    // MARK: Core functionality

    private func startSearch() {

        searchField.isEnabled = false

        if let searchTerm = getSearchTerm() {
            downloadImageUrls(searchText: searchTerm) {
                // Completion handler
                self.searchField.isEnabled = true
            }
        } else {
            searchField.isEnabled = true
        }
    }

    private func getSearchTerm() -> String? {
        guard let searchTerm = searchField.text else {
            fatalError("Cannot retrieve search term")
        }

        if searchTerm.isEmpty {
            popupAlert(title: "Empty search field", message: "Please enter a search term.", alertStyle: .alert, actionTitles: ["Cancel", "New search"], actionStyles: [.cancel, .default], actions: [cancelHandler(alertAction:), nil])
            return nil
        }

        return searchTerm
    }

    private func downloadImageUrls(searchText: String, completion: (() -> Void)? = nil) {

        NetworkClient.downloadImageUrlList(searchTerm: searchText) { (urlList, statusResponse, error) in
            guard error == nil else {
                let errorMessage = statusResponse?.message ?? error?.localizedDescription ?? ""
                self.popupAlert(title: "Download failed", message: errorMessage, alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.cancel], actions: [nil])
                completion?()
                return
            }

            guard let urlList = urlList else {
                completion?()
                return
            }

            let listSize = urlList.count

            // Default-initialize array of search results
            self.searchResults = [SearchResult](repeating: SearchResult(data: nil), count: listSize)

            if listSize == 0 {
                self.popupAlert(title: "No result", message: error?.localizedDescription ?? "Your search query for \"\(searchText)\" did not achieve a result.", alertStyle: .alert, actionTitles: ["Cancel", "New search"], actionStyles: [.cancel, .default], actions: [self.cancelHandler(alertAction:), nil])
            } else {

                for (index, urlString) in urlList.enumerated() {
                    self.downloadImage(from: urlString, to: index)
                }
            }

            self.collectionView?.reloadData()

            completion?()
        }
    }

    private func downloadImage(from urlString: String, to arrayIndex: Int) {

        if let url = URL(string: urlString) {

            // Query image from given url
            NetworkClient.downloadImage(from: url) { imgData in
                if let imgData = imgData {

                    self.searchResults[arrayIndex] = SearchResult(data: imgData)

                } else {
                    print("Could not download image")
                }

                // Trigger collection view to reload
                self.searchResults[arrayIndex].isPending = false
                let indexPath = IndexPath(item: arrayIndex, section: 0)
                self.collectionView.reloadItems(at: [indexPath])
            }
        } else {
            print("Invalid URL")

            // Trigger to reload, i.e. stop activity indicator here
            searchResults[arrayIndex].isPending = false
            let indexPath = IndexPath(item: arrayIndex, section: 0)
            collectionView.reloadItems(at: [indexPath])
        }
    }


    // MARK: Handler

    func cancelHandler(alertAction: UIAlertAction) {
        dismiss(animated: true, completion: nil)
    }


    // MARK: CollectionView DataSource & Delegation

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrSearchCell

        if searchResults[indexPath.item].isPending {

            cell.activityIndicator.startAnimating()

            cell.imageView.image = nil
            cell.imageView.backgroundColor = .lightGray

        } else {

            cell.activityIndicator.stopAnimating()

            if let imgData = searchResults[indexPath.item].data {
                cell.imageView.image = UIImage(data: imgData)

            } else {
                cell.imageView.image = UIImage(systemName: "photo") // placeholder
            }
            cell.imageView.backgroundColor = .white
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // Prevent access to search results array in phase of being overwritten
        if searchField.isEnabled,
           let selectedImage = searchResults[indexPath.item].data {

            returnImage?(selectedImage)
            dismiss(animated: true, completion: nil)
        }
    }
}


// MARK: Collection View Flow Layout Delegation

extension FlickrSearchCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // Items per row shall depend on UI orientation
        let itemsPerRow = (UIScreen.main.bounds.height > UIScreen.main.bounds.width) ? LayoutConstant.itemsPerRowPortrait : LayoutConstant.itemsPerRowLandscape

        let padding = (itemsPerRow + 1) * LayoutConstant.spacing
        let availableWidth = collectionView.bounds.width - padding
        let cellSize = availableWidth / itemsPerRow

        return CGSize(width: cellSize, height: cellSize)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        // Use equally spaced insets
        let inset = LayoutConstant.spacing

        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return LayoutConstant.spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return LayoutConstant.spacing
    }
}

extension FlickrSearchCollectionViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {

        // Clear textfield
        textField.text = ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        // Check whether former search query is still running
        for result in searchResults {
            if result.isPending {
                popupAlert(title: "Former query still running", message: "Please try again in a few moments.", alertStyle: .alert, actionTitles: ["OK"], actionStyles: [.default], actions: [nil])
                return
            }
        }

        // Else: Start a new search
        startSearch()
    }
}
