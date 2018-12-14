//
//  CollectionViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 11/12/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit
import SnapKit

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let dataManager = DataManager.shared
    
    private var reuseIdentifier = "DetailCell"
    
    private var objectsToShow: [MarvelObject]? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    private var isFavoriteCollectionView = false
    private var favoriteType: Type = .characters
    
    private var favoriteIds: [Int]? {
        if let favs = UserDefaults.standard.array(forKey: "\(favoriteType.rawValue)FavId") as? [Int] {
            return Array(Set(favs)).sorted()
        
        } else {
            // TODO: maybe show error message because they haven't stored any yet
            return nil
        }
    }

    var marvelObject: MarvelObject = MarvelObject(type: .characters, id: 0, name: "", thumbnail: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view)
            make.left.right.equalTo(view).inset(5)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if isFavoriteCollectionView {
            self.requestFavoriteData(forType: favoriteType)
        }
    }
    
    /**
     * ONLY for collectionview that is triggered by detailviewcontroller
     */
    func requestData() {
        
        let requestType: Type
        
        switch marvelObject.type {
        case .comics:
            requestType = .creators
        case .characters:
            requestType = .comics
        case .creators:
            requestType = .comics
        }
        
        dataManager.requestDataForDetailCollectionView(about: requestType, from: marvelObject) { values, success in
            if success {
                print("DetailCollectionViewController > Successfully downloaded DataForDetailCollectionView for \(self.marvelObject.type.rawValue).")
                
                self.objectsToShow = values
            }
        }
    }
    
    /**
     * ONLY for collectionview that is triggered by favorite tab
     */
    func requestFavoriteData(forType type: Type) {
        isFavoriteCollectionView = true
        favoriteType = type
        
        dataManager.requestDataForDetailCollectionView(about: type, byIds: favoriteIds ?? [0]) { values, success in
            if success {
                print("DetailCollectionViewController > Successfully downloaded DataForDetailCollectionView for \(type.rawValue).")
                
                self.objectsToShow = values
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
        
        // if collectionView is shown by favorite tab
        if isFavoriteCollectionView, let amountToShow = favoriteIds?.count {
            return amountToShow
        }
        
        // if collectionView is shown by marvel data or search tab
        switch marvelObject.type {
        case .comics:
            guard let comic = marvelObject as? Comic else {
                return 0
            }
            // TODO: implement for characters too
            return comic.creatorTotal ?? 0
            
        case .characters:
            guard let character = marvelObject as? Character, let comics = character.comics else {
                return 0
            }
            return comics.count
        default:
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let objectsToShow = objectsToShow, objectsToShow.count != 0, objectsToShow.count > indexPath.row else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MarvelCollectionViewCell else {
            print("CollectionViewController > CellType for \(self.marvelObject.type.rawValue) doesn't match MarvelCollectionViewCell.")
            return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        }
        
        cell.setupLayout()
        cell.marvelObject = objectsToShow[indexPath.row]
        
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

