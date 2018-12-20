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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Favorite \(favoriteType.rawValue.capitalizingFirstLetter())"
    }
    
    private var favoriteIds: [Int]? {
        if let favs = UserDefaults.standard.array(forKey: "\(favoriteType.rawValue)FavId") as? [Int] {
            return Array(Set(favs)).sorted()
            
        } else {
            let alertController = UIAlertController(title: "No Favs",
                                                    message: "Well, looks like you have not stored anything yet! \nGo back to the Marvel Database and select some \(favoriteType.rawValue.capitalizingFirstLetter()) you would like to remember. Just click the heart icon next to the name in the Detailview. \nSee you soon again.",
                                                    preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                print("FavoriteCollectionViewController > User has pressed ok on alertcontroller.")
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
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
    
    @IBAction func deleteAllFavs(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete all",
                                                message: "Are you sure you want to delete all stored \(favoriteType.rawValue.capitalizingFirstLetter())?",
                                                preferredStyle: .alert)
        let actionDelete = UIAlertAction(title: "Delete", style: .default) { (action:UIAlertAction) in
            print("FavoriteCollectionViewController > User has pressed delete on alertcontroller.")
            self.deleteAll()
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction) in
            print("FavoriteCollectionViewController > User has pressed cancel on alertcontroller.")
        }
        alertController.addAction(actionDelete)
        alertController.addAction(actionCancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func deleteAll() {
        UserDefaults.standard.removeObject(forKey: "\(favoriteType.rawValue)FavId")
        objectsToShow = nil
    }
    
}
