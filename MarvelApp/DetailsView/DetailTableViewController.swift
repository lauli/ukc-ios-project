//
//  DetailTableViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 16/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {

    var marvelType: Type = .characters
    var marvelObject: MarvelObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: "DetailComicsCell")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailComicsCell", for: indexPath) as? DetailTableViewCell else {
            return tableView.dequeueReusableCell(withIdentifier: "DetailComicsCell", for: indexPath)
        }
        
        cell.marvelObject = marvelObject
        cell.marvelType = marvelType
        
        return cell
    }
    
    override func reloadInputViews() {
        super.reloadInputViews()
        
        if let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? DetailTableViewCell {
            cell.updateInformationOnLabels()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailCollectionViewController = segue.destination as? DetailCollectionViewController else {
                return
        }
        
        detailCollectionViewController.marvelType = marvelType
        detailCollectionViewController.marvelObject = marvelObject
        detailCollectionViewController.requestData()
    }
}
