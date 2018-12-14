//
//  SearchViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 14/12/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var comicButton: UIButton!
    @IBOutlet weak var characterButton: UIButton!
    @IBOutlet weak var creatorButton: UIButton!
    @IBOutlet weak var collectionViewContainer: UIView!
    
    private var collectionViewController: CollectionViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        collectionViewContainer.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        collectionViewController.requestData(
        // TODO: figure out how to do this ^^
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let collectionViewController = segue.destination as? CollectionViewController {
            self.collectionViewController = collectionViewController
        }
    }

}
