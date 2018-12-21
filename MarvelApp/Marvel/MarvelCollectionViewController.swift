//
//  MarvelCollectionViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 13/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit
import SnapKit

class MarvelCollectionViewController: CollectionViewController, UICollectionViewDataSourcePrefetching {

    private var reuseIdentifier = "Cell"
    
    var marvelType: Type = .characters
    var isFetchInProgress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        
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
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataManager.totalAmountInDB[marvelType.rawValue] ?? 20
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell else {
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
    
}

extension MarvelCollectionViewController {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            requestData(20)
        }
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
}

