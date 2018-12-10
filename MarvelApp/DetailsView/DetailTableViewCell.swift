//
//  DetailTableViewCell.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 16/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    
    var marvelType: Type = .characters
    var marvelObject: MarvelObject? {
        didSet {
            updateInformationOnLabels()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func updateInformationOnLabels() {
        
        switch marvelType {
        case .characters:
            guard let character = marvelObject as? Character, let details = character.details else {
                return
            }
            
            // set title and amount
            titleLabel.text = "Comic"
            amountLabel.text = "\(details.amountOfComics ?? 0)"
            
            guard let information = details.comics else {
                return
            }
            
            // set information
            informationLabel.text = (information.first ?? "") + ","
            for comic in information {
                informationLabel.text?.append(" \(comic),")
            }
            informationLabel.text?.append("...")
            
        default:
            titleLabel.text = ""
        }
        
    }
    
}
