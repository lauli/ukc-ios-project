//
//  FavoritesViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 13/12/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit
import SnapKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var imageComics: UIImageView!
    @IBOutlet weak var imageCharacters: UIImageView!
    @IBOutlet weak var imageCreators: UIImageView!
    
    @IBOutlet weak var labelComics: UILabel!
    @IBOutlet weak var labelCharacters: UILabel!
    @IBOutlet weak var labelCreators: UILabel!
    
    private var idsOfObjectsToBeShown = [Int]()
    private var typeToBeShown: Type = .characters
    private let destinationViewController = "DetailCollectionViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGestureRecognizer()
        setupLayout()
    }
    
    private func setupLayout() {
        
        let heightForImages = (contentView.bounds.size.height + 90)/3
        
        imageComics.snp.makeConstraints { make in
            make.left.right.top.equalTo(contentView)
            make.height.equalTo(heightForImages)
        }

        imageCharacters.snp.makeConstraints { make in
            make.left.right.equalTo(contentView)
            make.top.equalTo(imageComics.snp.bottom).offset(2)
            make.height.equalTo(heightForImages)
        }

        imageCreators.snp.makeConstraints { make in
            make.left.right.equalTo(contentView)
            make.top.equalTo(imageCharacters.snp.bottom).offset(2)
            make.height.equalTo(heightForImages)
        }
        
        imageComics.alpha = 0.75
        imageCharacters.alpha = 0.75
        imageCreators.alpha = 0.75
        
        labelComics.snp.makeConstraints { make in
            make.center.equalTo(imageComics)
        }
        labelCharacters.snp.makeConstraints { make in
            make.center.equalTo(imageCharacters)
        }
        labelCreators.snp.makeConstraints { make in
            make.center.equalTo(imageCreators)
        }
    }
    
    private func setupGestureRecognizer() {
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageComicsTapped(tapGestureRecognizer:)))
        imageComics.isUserInteractionEnabled = true
        imageComics.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageCharactersTapped(tapGestureRecognizer:)))
        imageCharacters.isUserInteractionEnabled = true
        imageCharacters.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageCreatorsTapped(tapGestureRecognizer:)))
        imageCreators.isUserInteractionEnabled = true
        imageCreators.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func imageComicsTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        typeToBeShown = .comics
        showCollectionView()
    }
    
    @objc private func imageCharactersTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        typeToBeShown = .characters
        showCollectionView()
    }
    
    @objc private func imageCreatorsTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        typeToBeShown = .creators
        showCollectionView()
    }
    
    // MARK: - Navigation
    
    private func showCollectionView() {
        performSegue(withIdentifier: "showCollectionViewForFavs", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let collectionViewController = segue.destination as? FavoriteCollectionViewController else {
            return
        }
        collectionViewController.requestData(forType: typeToBeShown)
    }

}
