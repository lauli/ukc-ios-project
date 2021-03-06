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
    
    private var reuseIdentifier = "DetailCell"
    
    let dataManager = DataManager.shared
    var marvelObject: MarvelObject = MarvelObject(type: .characters, id: 0, name: "", thumbnail: "")

    var objectsToShow: [MarvelObject]? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view)
            make.left.right.equalTo(view).inset(5)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailsViewController = segue.destination as? DetailViewController,
            let cell = sender as? CollectionViewCell else {
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
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let objectsToShow = objectsToShow, objectsToShow.count != 0, objectsToShow.count > indexPath.row else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell else {
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
        let width = UIScreen.main.bounds.width * 0.95
        let height = UIScreen.main.bounds.height * 0.40
        return CGSize(width: width, height: height)
    }
    
}

