//
//  SearchViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 14/12/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var comicButton: UIButton!
    @IBOutlet weak var characterButton: UIButton!
    @IBOutlet weak var creatorButton: UIButton!
    @IBOutlet weak var collectionViewContainer: UIView!
    
    private let dataManager = DataManager.shared
    private var collectionViewController: SearchCollectionViewController!
    
    private var selectedType: Type = .characters
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        collectionViewContainer.isHidden = false
        
        setupLayout()
        // Do any additional setup after loading the view.
    }
    
    private func setupLayout() {
        
        collectionViewContainer.snp.makeConstraints { make in
            make.top.equalTo(comicButton.snp.bottom).offset(5)
            make.left.right.bottom.equalTo(view)
        }
        
        comicButton.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.left.equalTo(view)
            make.width.equalTo(view.bounds.width / 3)
        }
        comicButton.layer.borderColor = UIColor.gray.cgColor
        comicButton.layer.borderWidth = 1
        comicButton.layer.cornerRadius = 10
        
        characterButton.snp.makeConstraints { make in
            make.top.equalTo(comicButton)
            make.left.equalTo(comicButton.snp.right)
            make.width.equalTo(comicButton)
        }
        characterButton.layer.borderColor = UIColor.gray.cgColor
        characterButton.layer.borderWidth = 1
        characterButton.layer.cornerRadius = 10
        
        creatorButton.snp.makeConstraints { make in
            make.centerY.equalTo(characterButton)
            make.left.equalTo(characterButton.snp.right)
            make.width.equalTo(comicButton)
        }
        creatorButton.layer.borderColor = UIColor.gray.cgColor
        creatorButton.layer.borderWidth = 1
        creatorButton.layer.cornerRadius = 10
        
        changeLayoutForSelectedButtons(character: true)
    }
    
    private func changeLayoutForSelectedButtons(comic: Bool = false, character: Bool = false, creator: Bool = false) {
        
        comicButton.backgroundColor = comic ? .gray : .white
        comicButton.setTitleColor(comic ? .white : .gray, for: .normal)
        
        characterButton.backgroundColor = character ? .gray : .white
        characterButton.setTitleColor(character ? .white : .gray, for: .normal)
        
        creatorButton.backgroundColor = creator ? .gray : .white
        creatorButton.setTitleColor(creator ? .white : .gray, for: .normal)
        
        if comic {
            selectedType = .comics
        } else if character {
            selectedType = .characters
        } else {
            selectedType = .creators
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        print(searchBar.text ?? "SearchViewController > No input found in searchbar.")
        
        guard let nameToFind = searchBar.text else {
            return
        }
        
        collectionViewController.requestData(forType: selectedType, forName: nameToFind)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBarSearchButtonClicked(searchBar)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let collectionViewController = segue.destination as? SearchCollectionViewController {
            self.collectionViewController = collectionViewController
        }
    }
    
}
