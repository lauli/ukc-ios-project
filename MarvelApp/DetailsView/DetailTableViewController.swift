//
//  DetailTableViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 16/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {

    var marvelObject: MarvelObject = MarvelObject(type: .characters, id: 0, name: "", thumbnail: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero) // TODO: maybe add sharing feature here?
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch marvelObject.type {
        case .comics:
            return 2
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailComicsCell", for: indexPath) as? DetailTableViewCell else {
            return tableView.dequeueReusableCell(withIdentifier: "DetailComicsCell", for: indexPath)
        }
        
        cell.marvelObject = marvelObject
        
        return cell
    }
    
    override func reloadInputViews() {
        super.reloadInputViews()
        
        if let cell = self.tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? DetailTableViewCell {
            cell.updateInformationOnLabels()
        }
        if let cell = self.tableView.cellForRow(at: IndexPath(item: 1, section: 0)) as? DetailTableViewCell {
            cell.updateInformationOnLabels(byIndex: 1)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailCollectionViewController = segue.destination as? DetailCollectionViewController else {
                return
        }
        
        detailCollectionViewController.marvelObject = marvelObject
        detailCollectionViewController.requestData()
    }
    
    @IBAction func arrowButtonTapped(_ sender: UIButton) {
        
        guard let cell = sender.superview?.superview as? DetailTableViewCell else {
            return
        }

        if cell.informationLabel.isHidden {
            cell.showInformationLabel(true)
        } else {
            cell.showInformationLabel(false)
        }

    }
    
}
