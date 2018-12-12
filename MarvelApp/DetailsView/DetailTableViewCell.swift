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
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var arrowButton: UIButton!
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
    }
    
    private func setupLayout() {
        
        setupContentConstraints(height: 50)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(20)
            make.top.equalTo(contentView)
        }
        
        arrowButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel)
            make.right.equalTo(contentView).inset(20)
            make.height.width.equalTo(20)
        }
        arrowButton.setBackgroundImage(UIImage(named: "arrow-down"), for: .normal)
        arrowButton.setTitle("", for: .normal)
        
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel)
            make.right.equalTo(arrowButton).inset(30)
        }
        
        informationLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalTo(amountLabel)
            make.top.equalTo(titleLabel).offset(50)
        }
        informationLabel.numberOfLines = 0
        informationLabel.isHidden = true
        
        showMoreButton.snp.makeConstraints { make in
            make.top.equalTo(informationLabel.snp.bottom).offset(10)
            make.bottom.equalTo(contentView).inset(10)
            make.height.equalTo(15)
            make.centerX.equalTo(contentView)
        }
        showMoreButton.isHidden = true
        
        showInformationLabel(false)
    }
    
    func updateInformationOnLabels(byIndex index: Int = 0) {
        
        switch marvelType {
        case .comics:
            guard let comic = marvelObject as? Comic else {
                return
            }
            
            switch index {
            case 0:
                titleLabel.text = "Character appearances:"
                amountLabel.text = "\(comic.characterTotal ?? 0)"
                setupInformationLabel(for: comic.characters ?? [String]())
                
            case 1:
                titleLabel.text = "Creators involved:"
                amountLabel.text = "\(comic.creatorTotal ?? 0)"
                setupInformationLabel(for: comic.creators ?? [String]())
                
            default:
                break
            }
            

        case .characters:
            guard let character = marvelObject as? Character, let details = character.details else {
                return
            }
            
            // set title and amount
            titleLabel.text = "Number of Comic Appearances:"
            amountLabel.text = "\(details.amountOfComics ?? 0)"
            
            setupInformationLabel(for: details.comics ?? [String]())
            
        default:
            titleLabel.text = ""
        }
        
    }
    
    func showInformationLabel(_ show: Bool) {
        if show {
            informationLabel.isHidden = false
            showMoreButton.isHidden = false
            arrowButton.setBackgroundImage(UIImage(named: "arrow-up"), for: .normal)
            
        } else {
            informationLabel.isHidden = true
            showMoreButton.isHidden = true
            arrowButton.setBackgroundImage(UIImage(named: "arrow-down"), for: .normal)
        }
        
        resetHeightForContentView()
    }
    
    private func resetHeightForContentView() {
        let height: CGFloat
        
        if showMoreButton.isHidden {
            height = titleLabel.bounds.size.height + 30
        
        } else {
            let informationLabelHeight = informationLabel.text?.height(constraintedWidth: informationLabel.bounds.width,
                                                                       font: informationLabel.font)
            
            height = titleLabel.bounds.size.height + showMoreButton.bounds.size.height + informationLabelHeight! + 90
        }

        setupContentConstraints(height: height)
    }
    
    private func setupContentConstraints(height: CGFloat) {
        let newCellSubViewsFrame = CGRect(x: 0, y: 0,
                                          width: self.frame.size.width, height: height)
        let newCellViewFrame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y,
                                      width:self.frame.size.width, height: height)
        
        self.contentView.frame = newCellSubViewsFrame
        self.contentView.bounds = newCellSubViewsFrame
        self.backgroundView?.frame = newCellSubViewsFrame
        self.accessoryView?.frame = newCellSubViewsFrame
        self.frame = newCellViewFrame
    }
    
    private func setupInformationLabel(for array: [String]) {
        if array.count == 0 {
            return
        }
        
        informationLabel.text = (array.first ?? "") + ","
        for value in array {
            informationLabel.text?.append(" \(value),")
        }
        informationLabel.text?.append("...")
    }
    
}

extension String {
    func height(constraintedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = self
        label.font = font
        label.sizeToFit()
        
        return label.frame.height
    }
}
