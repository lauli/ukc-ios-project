//
//  DetailTableViewCell.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 16/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit
import SnapKit

class DetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    
    var marvelType: Type = .characters
    var marvelObject: MarvelObject?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func setupLayout() {
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(20)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.right.equalTo(contentView).inset(20)
        }
        
        informationLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(amountLabel)
            make.top.equalTo(titleLabel).offset(50)
        }
        informationLabel.numberOfLines = 0
        
        showMoreButton.snp.makeConstraints { make in
            make.top.equalTo(informationLabel.snp.bottom).offset(30)
        }
    }
    
    func updateInformationOnLabels() {
        
        switch marvelType {
        case .characters:
            guard let character = marvelObject as? Character, let details = character.details else {
                return
            }
            
            // set title and amount
            titleLabel.text = "Number of Comics:"
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
