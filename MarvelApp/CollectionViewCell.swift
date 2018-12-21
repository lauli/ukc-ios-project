//
//  MarvelCollectionViewCell.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 14/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet var title: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var favorite = false
    
    var marvelObject: MarvelObject? {
        didSet {
            guard let marvelObject = marvelObject else {
                return
            }
            
            if let thumbnail = marvelObject.thumbnail {
                self.showPicture(forImageUrl: thumbnail)
            }
            title.text = marvelObject.name
            updateTitleLabelLayout()
            self.isUserInteractionEnabled = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupLayout() {
        self.isUserInteractionEnabled = false
        
        indicatorView.startAnimating()
        imageView.contentMode = .scaleAspectFill
        
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalTo(contentView)
            make.height.equalTo(contentView.snp.height).inset(30)
        }
        
        titleView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.left.right.equalTo(contentView)
            make.bottom.equalTo(contentView).inset(10)
        }
        
        title.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(titleView).inset(5)
        }
        
        indicatorView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(50)
            make.centerY.equalTo(contentView)
            make.centerX.equalTo(contentView)
        }

        contentView.backgroundColor = UIColor(white: 0.75, alpha: 1)
        titleView.backgroundColor = .white
        layer.cornerRadius = 15
        
        updateTitleLabelLayout()
    }
    
    private func updateTitleLabelLayout() {
        if marvelObject != nil {
            title.font = title.font.withSize(20)
            title.textAlignment = .left
        } else {
            title.font = title.font.withSize(12)
            title.textAlignment = .center
        }
    }
    
    private func showPicture(forImageUrl url: String) {
        
        DataManager().requestImage(forImageUrl: url) { image, urlToCheckIfItIsSame in
            
            if urlToCheckIfItIsSame != self.marvelObject?.thumbnail {
                // old fetch request, don't set image
                return
            }
            
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
                self.contentView.backgroundColor = UIColor(white: 0.25, alpha: 1)
                
                if image != nil {
                    self.imageView.image = image
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        marvelObject = nil
        indicatorView.startAnimating()
        title.text = "Fetching Data"
    }
}
