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
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    private let dataManager = DataManager.shared
    private var collectionViewController: SearchCollectionViewController!
    
    private var selectedType: Type = .characters
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Search"
        searchBar.delegate = self
        collectionViewContainer.isHidden = false
        indicatorView.isHidden = true
        setupLayout()
        // Do any additional setup after loading the view.
    }
    
    private func setupLayout() {
        
        //view.backgroundColor = UIColor(white: 0.77, alpha: 1)
        
        collectionViewContainer.snp.makeConstraints { make in
            make.top.equalTo(comicButton.snp.bottom).offset(10)
            make.left.right.bottom.equalTo(view)
        }
        
        comicButton.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.left.equalTo(view)
            make.width.equalTo(view.bounds.width / 3)
        }
        comicButton.layer.borderColor = UIColor.buttonBlue.cgColor
        comicButton.layer.borderWidth = 1
        comicButton.layer.cornerRadius = 10
        
        characterButton.snp.makeConstraints { make in
            make.top.equalTo(comicButton)
            make.left.equalTo(comicButton.snp.right)
            make.width.equalTo(comicButton)
        }
        characterButton.layer.borderColor = UIColor.buttonBlue.cgColor
        characterButton.layer.borderWidth = 1
        characterButton.layer.cornerRadius = 10
        
        creatorButton.snp.makeConstraints { make in
            make.centerY.equalTo(characterButton)
            make.left.equalTo(characterButton.snp.right)
            make.width.equalTo(comicButton)
        }
        creatorButton.layer.borderColor = UIColor.buttonBlue.cgColor
        creatorButton.layer.borderWidth = 1
        creatorButton.layer.cornerRadius = 10
        
        changeLayoutForSelectedButtons(character: true)
    }
    
    private func changeLayoutForSelectedButtons(comic: Bool = false, character: Bool = false, creator: Bool = false) {
        
        comicButton.backgroundColor = comic ? UIColor.buttonBlue : .white
        comicButton.setTitleColor(comic ? .white : UIColor.buttonBlue, for: .normal)
        
        characterButton.backgroundColor = character ? UIColor.buttonBlue : .white
        characterButton.setTitleColor(character ? .white : UIColor.buttonBlue, for: .normal)
        
        creatorButton.backgroundColor = creator ? UIColor.buttonBlue : .white
        creatorButton.setTitleColor(creator ? .white : UIColor.buttonBlue, for: .normal)
        
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
        
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        collectionViewController.requestData(forType: selectedType, forName: nameToFind)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.collectionViewController.objectsToShow != nil || self.collectionViewController.nothingFound {
                self.timer?.invalidate()
                self.timer = nil
                self.indicatorView.stopAnimating()
                self.indicatorView.isHidden = true
            }
            if self.collectionViewController.nothingFound {
                let ac = UIAlertController(title: "Nothing Found", message: "Please try another search request. (i.e. Spider-Man, Iron Man, Captain America, ...)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        }
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
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        switch sender.titleLabel?.text {
        case "Comic":
            selectedType = .comics
            changeLayoutForSelectedButtons(comic: true)
        case "Creator":
            selectedType = .creators
            changeLayoutForSelectedButtons(creator: true)
        default:
            selectedType = .characters
            changeLayoutForSelectedButtons(character: true)
        }
        
        collectionViewController.objectsToShow = nil
    }
    
    
}
