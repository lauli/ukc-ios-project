//
//  FavoriteCollectionViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 19.12.18.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit

final class FavoriteCollectionViewController: CollectionViewController {
    
    private var favoriteType: Type = .characters
    
    private var favoriteIds: [Int]? {
        if let favs = UserDefaults.standard.array(forKey: "\(favoriteType.rawValue)FavId") as? [Int] {
            return Array(Set(favs)).sorted()
            
        } else {
            // TODO: maybe show error message because they haven't stored any yet
            return nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.requestData(forType: favoriteType)
    }
    
    func requestData(forType type: Type) {
        favoriteType = type
        
        dataManager.requestDataForDetailCollectionView(about: type, byIds: favoriteIds ?? [0]) { values, success in
            if success {
                print("DetailCollectionViewController > Successfully downloaded DataForDetailCollectionView for \(type.rawValue).")
                
                self.objectsToShow = values
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteIds?.count ?? 0
    }
    
    
}
