//
//  DetailCollectionViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 19.12.18.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit

class DetailCollectionViewController: CollectionViewController {
    
    func requestData() {
        
        let requestType: Type
        let namesToFind: [String]?
        
        switch marvelObject.type {
        case .comics:
            requestType = .creators
            namesToFind = marvelObject.creators
        case .characters:
            requestType = .comics
            namesToFind = marvelObject.characters
        case .creators:
            requestType = .comics
            namesToFind = marvelObject.creators
        }
        
        dataManager.requestDataForDetailCollectionView(about: requestType, from: namesToFind) { values, success in
            if success {
                print("DetailCollectionViewController > Successfully downloaded DataForDetailCollectionView for \(self.marvelObject.type.rawValue).")
                
                self.objectsToShow = values
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch marvelObject.type {
        case .comics:
            if let comic = marvelObject as? Comic {
                return comic.creatorTotal ?? 0
            }
            
        case .characters:
            if let character = marvelObject as? Character {
                return character.comicTotal ?? 0
            }
            
            
        case .creators:
            if let creator = marvelObject as? Creator {
                return creator.comicTotal ?? 0
            }
        }
        
        return 0
    }
    
}
