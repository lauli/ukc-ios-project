
//
//  SearchCollectionViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 19.12.18.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit

final class SearchCollectionViewController: CollectionViewController {
    
    func requestData(forType type: Type, forName name: String) {
        self.objectsToShow = nil
        
        dataManager.requestDataForDetailCollectionView(about: type, from: [name], forSearchTab: true) { values, success in
            if success {
                print("DetailCollectionViewController > Successfully downloaded DataForDetailCollectionView for \(type.rawValue).")
                
                self.objectsToShow = values
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objectsToShow?.count ?? 0
    }
    
    
}
