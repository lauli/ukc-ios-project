//
//  MarvelCollectionViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 13/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit
import SnapKit

class MarvelCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    
    private let dataManager = DataManager.shared
    
    private var reuseIdentifier = "Cell"
    private var isFetchInProgress: Bool = false
    
    var marvelType: Type = .characters

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view)
            make.left.right.equalTo(view).inset(5)
        }

        requestData()
    }
    
    private func requestData(_ amount: Int = 30, forCellsAtIndexPaths indexPaths: [IndexPath]? = nil) {
        guard !isFetchInProgress else {
            return
        }

        isFetchInProgress = true
        
        dataManager.request(type: marvelType, amountOfObjectsToRequest: amount) { amountOfRetrievedObjects, success in
            self.isFetchInProgress = false
            if success {
                print("CollectionViewController > Successfully downloaded \(self.marvelType.rawValue) Data.")
                
                DispatchQueue.main.async {
                    if indexPaths != nil {
                        let indexPathsToReload = self.calculateIndexPathsToReload(byAmountsFetched: amountOfRetrievedObjects)
                        self.onFetchCompleted(with: indexPathsToReload)
                        
                    } else {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailsViewController = segue.destination as? DetailViewController,
            let cell = sender as? MarvelCollectionViewCell else {
                return
        }
        
        guard let marvelObject = cell.marvelObject, let indexPath = collectionView.indexPath(for: cell) else {
            return
        }

        detailsViewController.marvelObject = marvelObject
        detailsViewController.preDownloadedImage = cell.imageView?.image
        detailsViewController.requestDetails(atIndex: indexPath.row)
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataManager.totalAmountInDB[marvelType.rawValue] ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MarvelCollectionViewCell else {
            print("CollectionViewController > CellType for \(self.marvelType.rawValue) doesn't match MarvelCollectionViewCell.")
            return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        }
        
        cell.setupLayout()
        
        if !isLoadingCell(for: indexPath) {
            switch marvelType {
            case .comics:
                cell.marvelObject = dataManager.comics[indexPath.row]
            case .characters:
                cell.marvelObject = dataManager.characters[indexPath.row]
            case .creators:
                cell.marvelObject = dataManager.creators[indexPath.row]
            }
        }
        return cell
    }
    
    // MARK: - Cell Layout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width * 0.47
        let height = UIScreen.main.bounds.height * 0.33
        return CGSize(width: width, height: height)
    }

}

extension MarvelCollectionViewController {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            requestData(20)
        }
    }
    
    private func calculateIndexPathsToReload(byAmountsFetched amount: Int) -> [IndexPath] {
        let startIndex = collectionView.visibleCells.count - 1
        let endIndex = startIndex + amount
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        switch marvelType {
        case .comics:
            return indexPath.row >= dataManager.comics.count
        case .characters:
            return indexPath.row >= dataManager.characters.count
        case .creators:
            return indexPath.row >= dataManager.creators.count
        }
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleCells = collectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleCells).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            collectionView.isHidden = false
            collectionView.reloadData()
            return
        }
        
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        collectionView.reloadItems(at: indexPathsToReload)
    }
}

