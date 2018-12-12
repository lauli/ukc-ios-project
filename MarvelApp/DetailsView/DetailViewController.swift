//
//  ViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 12/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit
import SnapKit

class DetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var informationContainer: UIView!
    @IBOutlet weak var tableViewContainer: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    @IBOutlet weak var favButton: UIButton!
    
    private let dataManager = DataManager.shared
    private var isFav = false
    private var detailTableTableViewController: DetailTableViewController?

    
    var marvelType: Type = .characters
    var marvelObject: MarvelObject?
    var preDownloadedImage: UIImage?
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupCharacterLayout()
        setupFavButton()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.scrollIndicatorInsets = view.safeAreaInsets
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                               bottom: view.safeAreaInsets.bottom, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            
        case let viewController as DetailTableViewController:
            detailTableTableViewController = viewController
            detailTableTableViewController?.marvelObject = marvelObject
            detailTableTableViewController?.marvelType = marvelType
            
        default:
            break
        }
    }
    
    func requestDetails(forId id: Int, atIndex index: Int) {
        switch marvelType {
        case .comics:
            dataManager.requestComicDetails(forId: id, atIndex: index) { success in
                if success {
                    print("CollectionViewController > Successfully requested Comic Details.")
                    DispatchQueue.main.async {
                        self.detailTableTableViewController?.reloadInputViews()
                    }
                }
            }
        case .characters:
            dataManager.requestCharacterDetails(forId: id, atIndex: index) { success in
                if success {
                    print("CollectionViewController > Successfully requested Character Details.")
                    DispatchQueue.main.async {
                        self.detailTableTableViewController?.reloadInputViews()
                    }
                }
            }
            
        default:
            break
        }
    }
    
    private func setupLayout() {
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        
        imageView.image = UIImage(named: "default")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        scrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(view).offset(topbarHeight)
        }
        
        imageContainer.snp.makeConstraints { make in
            make.top.equalTo(scrollView)
            make.left.right.equalTo(view)
            make.height.equalTo(imageContainer.snp.width)
        }
        
        imageView.snp.makeConstraints { make in
            make.left.right.equalTo(imageContainer)
            make.top.equalTo(view).priority(.high)
            make.height.greaterThanOrEqualTo(imageContainer.snp.height).priority(.required)
            make.bottom.equalTo(imageContainer.snp.bottom)
        }
        
        informationContainer.snp.makeConstraints { make in
            make.top.equalTo(imageContainer.snp.bottom)
            make.left.right.equalTo(view)
            make.bottom.equalTo(scrollView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalTo(informationContainer).inset(14)
            make.height.equalTo(titleLabel.optimalHeight)
        }
        
        favButton.snp.makeConstraints { make in
            make.top.right.equalTo(titleLabel)
            make.width.height.equalTo(32)
        }
        
        tableViewContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.right.equalTo(informationContainer)
            make.height.equalTo(400)
        }
        
        bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(tableViewContainer.snp.bottom)
            make.right.bottom.equalTo(informationContainer).inset(14)
            make.height.equalTo(50)
        }
        bottomLabel.isHidden = true
    }
    
    private func setupCharacterLayout() {
        guard let object = marvelObject else {
            print("DetailViewController > setupCharacter() -> Couldn't cast object to the type Character.")
            return
        }
        
        if let image = preDownloadedImage {
            // check if there the picture is already downloaded
            imageView.image = image
            
        } else if let url = object.thumbnail {
            // if not, check if there is an url, if not, leave the default image
            showPicture(forImageUrl: url)
        }
        
        titleLabel.text = object.name
    }
    
    private func showPicture(forImageUrl url: String) {
        DataManager().requestImage(forImageUrl: url) { image, success in
            if success {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }
    
    private func setupFavButton() {
        var imageName = "fav-empty"
        favButton.setTitle("", for: .normal)
        
        guard let favs = UserDefaults.standard.array(forKey: "\(marvelType.rawValue)FavId") as? [Int] else {
            favButton.setBackgroundImage(UIImage(named: imageName), for: .normal)
            return
        }
        
        
        for id in favs {
            if id == marvelObject?.id {
                imageName = "fav-full"
                isFav = true
            }
        }
        
        favButton.setBackgroundImage(UIImage(named: imageName), for: .normal)
    }
    
    @IBAction func favButtonTapped(_ sender: Any) {
        if UserDefaults.standard.array(forKey: "\(marvelType.rawValue)FavId") == nil {
            UserDefaults.standard.set([marvelObject?.id], forKey: "\(marvelType.rawValue)FavId")
        }
        
        var favs = UserDefaults.standard.array(forKey: "\(marvelType.rawValue)FavId") as! [Int]
        
        if isFav {
            let newFavs = favs.filter {$0 != marvelObject?.id}
            UserDefaults.standard.set(newFavs, forKey: "\(marvelType.rawValue)FavId")
            
            favButton.setBackgroundImage(UIImage(named: "fav-empty"), for: .normal)
        
        } else if let marvelObject = marvelObject {
            favs.append(marvelObject.id)
            UserDefaults.standard.set(favs, forKey: "\(marvelType.rawValue)FavId")
            
            favButton.setBackgroundImage(UIImage(named: "fav-full"), for: .normal)
        }
        
        isFav = !isFav
    }

}

