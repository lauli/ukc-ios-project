//
//  DetailCollectionViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 11/12/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit
import SnapKit

class DetailCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let dataManager = DataManager.shared
    
    private var reuseIdentifier = "DetailCell"
    
    private var objectsToShow: [MarvelObject]? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var marvelType: Type = .characters
    var marvelObject: MarvelObject?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view)
            make.left.right.equalTo(view).inset(5)
        }
    }
    
    func requestData() {
        
        guard let marvelObject = marvelObject else {
            return
        }
        
        let requestType: Type
        
        switch marvelType {
        case .comics:
            requestType = .creators
        case .characters:
            requestType = .comics
        default:
            return
        }
        
        dataManager.requestDataForDetailCollectionView(about: requestType, from: marvelObject) { values, success in
            if success {
                print("DetailCollectionViewController > Successfully downloaded DataForDetailCollectionView for \(self.marvelType.rawValue).")
                
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
        
        guard let id = cell.marvelObject?.id, let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        detailsViewController.marvelType = marvelType
        detailsViewController.marvelObject = cell.marvelObject
        detailsViewController.preDownloadedImage = cell.imageView?.image
        detailsViewController.requestDetails(forId: id, atIndex: indexPath.row)
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch marvelType {
        case .comics:
            guard let comic = marvelObject as? Comic else {
                return 0
            }
            // TODO: implement for characters too
            return comic.creatorTotal ?? 0
            
        case .characters:
            guard let character = marvelObject as? Character, let comics = character.details?.comics else {
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
            print("CollectionViewController > CellType for \(self.marvelType.rawValue) doesn't match MarvelCollectionViewCell.")
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

