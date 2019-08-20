//
//  RequestsViewController.swift
//  Wormholy-iOS
//
//  Created by Paolo Musolino on 13/04/18.
//  Copyright © 2018 Wormholy. All rights reserved.
//

import UIKit

class RequestsViewController: WHBaseViewController {

    @IBOutlet weak var collectionView: WHCollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!

    private var items: [RequestModel] = []
    private var searchResults: [RequestModel]?

    private var searchController: UISearchController?
    private var prototypeCell: RequestCell!
    private var storageToken: Storage.Token?

    private var isSearching: Bool {
        return searchResults != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSearchController()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "More", style: .plain, target: self, action: #selector(openActionSheet))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))

        let nib = UINib(nibName: "RequestCell", bundle:WHBundle.getBundle())
        prototypeCell = (nib.instantiate(withOwner: nil, options: nil)[0] as! RequestCell)
        collectionView?.register(nib, forCellWithReuseIdentifier: "RequestCell")
        collectionView.reloadData()

        storageToken = Storage.shared.observe { [weak self] change in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch change {
                case let .appended(items):
                    self.items.append(contentsOf: items)

                    if !self.isSearching {
                        self.collectionView.insertItems(
                            at: (0 ..< items.count).map { IndexPath(item: $0, section: 0) }
                        )
                    }
                case let .removed(range):
                    self.items.removeSubrange(range)

                    if !self.isSearching {
                        self.collectionView.deleteItems(
                            at: range.map { IndexPath(item: self.presentationIndex(fromModelIndex: $0), section: 0) }
                        )
                    }
                case let .updated(item, at: index):
                    self.items[index] = item

                    if !self.isSearching {
                        self.collectionView.reloadItems(at: [
                            IndexPath(item: self.presentationIndex(fromModelIndex: index), section: 0)
                        ])
                    }
                case .cleared:
                    self.searchResults = nil
                    self.items = []
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    //  MARK: - Search
    func addSearchController(){
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        if #available(iOS 9.1, *) {
            searchController?.obscuresBackgroundDuringPresentation = false
        } else {
            // Fallback
        }
        searchController?.searchBar.placeholder = "Search URL"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            navigationItem.titleView = searchController?.searchBar
        }
        definesPresentationContext = true
    }

    // MARK: - Actions
    @objc func openActionSheet(){
        let ac = UIAlertController(title: "Wormholy", message: "Choose an option", preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Clear", style: .default) { [weak self] (action) in
            self?.clearRequests()
        })
        ac.addAction(UIAlertAction(title: "Share", style: .default) { [weak self] (action) in
            self?.shareContent()
        })
        ac.addAction(UIAlertAction(title: "Close", style: .cancel) { (action) in
        })
        if UIDevice.current.userInterfaceIdiom == .pad {
            ac.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        }
        present(ac, animated: true, completion: nil)
    }
    
    func clearRequests() {
        Storage.shared.clearRequests()
    }
    
    func shareContent(){
        var text = ""
        for request in items {
            text = text + RequestModelBeautifier.txtExport(request: request)
        }
        let textShare = [text]
        let customItem = CustomActivity(title: "Save to the desktop", image: UIImage(named: "activity_icon", in: WHBundle.getBundle(), compatibleWith: nil)) { (sharedItems) in
            guard let sharedStrings = sharedItems as? [String] else { return }
            
            for string in sharedStrings {
                FileHandler.writeTxtFileOnDesktop(text: string, fileName: "\(Int(Date().timeIntervalSince1970))-wormholy.txt")
            }
        }
        let activityViewController = UIActivityViewController(activityItems: textShare, applicationActivities: [customItem])
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    @objc func done(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func openRequestDetailVC(request: RequestModel){
        let storyboard = UIStoryboard(name: "Flow", bundle: WHBundle.getBundle())
        if let requestDetailVC = storyboard.instantiateViewController(withIdentifier: "RequestDetailViewController") as? RequestDetailViewController{
            requestDetailVC.request = request
            self.show(requestDetailVC, sender: self)
        }
    }

    func modelIndex(fromPresentationIndex index: Int) -> Int {
        return items.count - index - 1
    }

    func presentationIndex(fromModelIndex index: Int) -> Int {
        return items.count - index - 1
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: newRequestNotification, object: nil)
    }
}

extension RequestsViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults?.count ?? items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RequestCell", for: indexPath) as! RequestCell

        if let searchResults = searchResults {
            cell.populate(request: searchResults[indexPath.row])
        } else {
            cell.populate(request: items[modelIndex(fromPresentationIndex: indexPath.row)])
        }

        return cell
    }
}

extension RequestsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let searchResults = searchResults {
            openRequestDetailVC(request: searchResults[indexPath.row])
        } else {
            openRequestDetailVC(request: items[modelIndex(fromPresentationIndex: indexPath.row)])
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let searchResults = searchResults {
            prototypeCell.populate(request: searchResults[indexPath.row])
        } else {
            prototypeCell.populate(request: items[modelIndex(fromPresentationIndex: indexPath.row)])
        }

        let width = collectionView.bounds.width
        let height = prototypeCell.contentView
            .systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                                     withHorizontalFittingPriority: .required,
                                     verticalFittingPriority: .fittingSizeLevel)
            .height

        return CGSize(width: width, height: height)
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension RequestsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            searchResults = items.filter { item in
                return item.url.range(of: text, options: .caseInsensitive) != nil
            }
        } else {
            searchResults = nil
        }

        collectionView.reloadData()
    }
}
