//
//  SearchViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 14/12/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import BTNavigationDropdownMenu
import UIKit
import SnapKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionViewContainer: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var backgroundView: UIImageView!
    
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
        
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        searchBar.barTintColor = UIColor(white: 0.95, alpha: 1)

        backgroundView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view).offset(50)
            make.left.right.equalTo(view).inset(50)
        }
        backgroundView.image = UIImage(named: "search-background")!
        backgroundView.contentMode = .scaleAspectFit
        backgroundView.alpha = 0.5
        
        collectionViewContainer.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }
        collectionViewContainer.isHidden = true
        addPickerView()
    }
    
    private func addPickerView() {
        let items = ["Comic", "Character", "Creator"]
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController,
                                                containerView: self.navigationController!.view,
                                                title: BTTitle.title("Click to select filter"),
                                                items: items)
        
        menuView.didSelectItemAtIndexHandler = { (indexPath: Int) -> () in
            switch indexPath {
            case 0: // comics
                self.selectedType = .comics
            case 1: // characters
                self.selectedType = .characters
            default: // creators
                self.selectedType = .creators
            }
            self.collectionViewController.objectsToShow = nil
            self.collectionViewContainer.isHidden = true
        }
        
        menuView.arrowTintColor = .black
        menuView.menuTitleColor = .buttonBlue
        menuView.maskBackgroundOpacity = 0.2
        menuView.cellSelectionColor = .buttonBlue
        menuView.cellHeight = 100
        
        self.navigationItem.titleView = menuView
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
            if self.collectionViewController.objectsToShow != nil {
                self.stopIndicatorAndTimer()
                self.collectionViewContainer.isHidden = false
            }
            
            if self.collectionViewController.nothingFound {
                self.stopIndicatorAndTimer()
                self.collectionViewContainer.isHidden = true
                let ac = UIAlertController(title: "Nothing Found", message: "Please try another search request. (i.e. Spider-Man, Iron Man, Captain America, ...)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        }
    }
    
    private func stopIndicatorAndTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.indicatorView.stopAnimating()
        self.indicatorView.isHidden = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if searchBar.text != "" {
            searchBarSearchButtonClicked(searchBar)
        } else {
            view.endEditing(true)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let collectionViewController = segue.destination as? SearchCollectionViewController {
            self.collectionViewController = collectionViewController
        }
    }
}
