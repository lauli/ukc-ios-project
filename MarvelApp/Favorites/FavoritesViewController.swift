//
//  FavoritesViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 13/12/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import LTMorphingLabel
import UIKit
import SnapKit

class FavoritesViewController: UIViewController, LTMorphingLabelDelegate {
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var imageComics: UIImageView!
    @IBOutlet weak var imageCharacters: UIImageView!
    @IBOutlet weak var imageCreators: UIImageView!
    
    @IBOutlet weak var labelComics: LTMorphingLabel!
    @IBOutlet weak var labelCharacters: LTMorphingLabel!
    @IBOutlet weak var labelCreators: LTMorphingLabel!
    
    private var idsOfObjectsToBeShown = [Int]()
    private var typeToBeShown: Type = .characters
    private let destinationViewController = "DetailCollectionViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Favorites"
        labelComics.delegate = self
        labelCharacters.delegate = self
        labelCreators.delegate = self
        setupGestureRecognizer()
        setupLayout()
    }
    
    private func setupLayout() {
        
        // images
        
        let heightForImages = (contentView.bounds.size.height + 90)/3
        
        imageComics.snp.makeConstraints { make in
            make.left.right.top.equalTo(contentView)
            make.height.equalTo(heightForImages)
        }
        imageComics.layer.borderWidth = 0.5
        imageComics.layer.borderColor = UIColor(white: 0.4, alpha: 1).cgColor

        imageCharacters.snp.makeConstraints { make in
            make.left.right.equalTo(contentView)
            make.top.equalTo(imageComics.snp.bottom).offset(2)
            make.height.equalTo(heightForImages)
        }
        imageCharacters.layer.borderWidth = 0.5
        imageCharacters.layer.borderColor = UIColor(white: 0.4, alpha: 1).cgColor

        imageCreators.snp.makeConstraints { make in
            make.left.right.equalTo(contentView)
            make.top.equalTo(imageCharacters.snp.bottom).offset(2)
            make.height.equalTo(heightForImages)
        }
        imageCreators.layer.borderWidth = 0.5
        imageCreators.layer.borderColor = UIColor(white: 0.4, alpha: 1).cgColor
        
        // --- labels
        //comics
        labelComics.snp.makeConstraints { make in
            make.center.equalTo(imageComics)
        }
        labelComics.text = "Zeitschriften"

        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            self.labelComics.text = "Comics"
        }
        
        //character
        labelCharacters.snp.makeConstraints { make in
            make.center.equalTo(imageCharacters)
        }
        labelCharacters.text = "Figuren"
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            self.labelCharacters.text = "Characters"
        }
        
        //creators
        labelCreators.snp.makeConstraints { make in
            make.center.equalTo(imageCreators)
        }
        labelCreators.text = "Authoren"

        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            self.labelCreators.text = "Creators"
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
