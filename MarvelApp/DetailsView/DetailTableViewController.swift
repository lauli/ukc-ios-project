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
        self.tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: "DetailComicsCell")

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailComicsCell", for: indexPath) as? DetailTableViewCell else {
            return tableView.dequeueReusableCell(withIdentifier: "DetailComicsCell", for: indexPath)
        }
        
        switch marvelType {
        case .comics:
            //cell.marvelObject = dataManager.comics[indexPath.row]
            break
        case .characters:
            cell.marvelObject = marvelObject
            cell.marvelType = marvelType
        case .creators:
            //cell.marvelObject = dataManager.creators[indexPath.row]
            break
        }
        
        return cell
    }

}
