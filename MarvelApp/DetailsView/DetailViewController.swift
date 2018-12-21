//
//  ViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 12/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import SnapKit
import Social
import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var informationContainer: UIView!
    @IBOutlet weak var tableViewContainer: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    @IBOutlet weak var favButton: UIButton!
    
    private let dataManager = DataManager.shared
    private var isFav = false
    private var detailTableTableViewController: DetailTableViewController?

    var marvelObject: MarvelObject = MarvelObject(type: .characters, id: 0, name: "", thumbnail: "")
    var preDownloadedImage: UIImage?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = marvelObject.name
        
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
            
        default:
            break
        }
    }
    
    func requestDetails(atIndex index: Int) {
        switch marvelObject.type {
        case .comics:
            dataManager.requestDetails(forObject: marvelObject as! Comic, atArrayIndex: index) { data, success in
                if success, let value = data {
                    print("CollectionViewController > Successfully requested Comic Details.")
                    self.marvelObject = value
                    self.update()
                }
            }
        case .characters:
            dataManager.requestDetails(forObject: marvelObject as! Character, atArrayIndex: index) { data, success in
                if success, let value = data {
                    print("CollectionViewController > Successfully requested Character Details.")
                    self.marvelObject = value
                    self.update()
                }
            }
            
        case .creators:
            dataManager.requestDetails(forObject: marvelObject as! Creator, atArrayIndex: index) { data, success in
                if success, let value = data {
                    print("CollectionViewController > Successfully requested Creator Details.")
                    self.marvelObject = value
                    self.update()
                }
            }
        }
    }
    
    private func update() {
        DispatchQueue.main.async {
            self.descriptionLabel.text = self.marvelObject.description
            self.updateDescriptionLabelConstraints()
            self.detailTableTableViewController?.reloadInputViews()
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
            make.top.left.equalTo(informationContainer).inset(14)
            make.right.equalTo(informationContainer).inset(30)
            make.height.equalTo(titleLabel.optimalHeight)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalTo(informationContainer).inset(14)
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(descriptionLabel.optimalHeight)
        }
        descriptionLabel.numberOfLines = 0
        
        favButton.snp.makeConstraints { make in
            make.top.right.equalTo(informationContainer).inset(14)
            make.width.height.equalTo(25)
        }
        
        tableViewContainer.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom)
            make.left.right.equalTo(informationContainer)
            make.height.equalTo(600)
        }
        
        bottomLabel.snp.makeConstraints { make in
            make.top.equalTo(tableViewContainer.snp.bottom)
            make.right.bottom.equalTo(informationContainer).inset(14)
            make.height.equalTo(50)
        }
        bottomLabel.isHidden = true
    }
    
    private func updateDescriptionLabelConstraints() {
        guard let height = descriptionLabel.text?.height(constraintedWidth: descriptionLabel.bounds.width, font: descriptionLabel.font) else {
            print("DetailViewController > Couldn't calculate height of description label.")
            return
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalTo(informationContainer).inset(14)
            make.right.equalTo(informationContainer).inset(14)
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(Int(height) + 1)
        }
        descriptionLabel.numberOfLines = 0
        
        tableViewContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Int(height) + 20)
            make.left.right.equalTo(descriptionLabel)
            make.height.equalTo(600)
        }
    }
    
    private func setupCharacterLayout() {
        if let image = preDownloadedImage {
            // check if there the picture is already downloaded
            imageView.image = image
            
        } else if let url = marvelObject.thumbnail {
            // if not, check if there is an url, if not, leave the default image
            showPicture(forImageUrl: url)
        }
        
        titleLabel.text = marvelObject.name
        descriptionLabel.text = marvelObject.description
    }
    
    private func showPicture(forImageUrl url: String) {
        DataManager().requestImage(forImageUrl: url) { image, _ in
            if image != nil {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }
    
    private func setupFavButton() {
        var imageName = "fav-empty"
        favButton.setTitle("", for: .normal)
        
        guard let favs = UserDefaults.standard.array(forKey: "\(marvelObject.type.rawValue)FavId") as? [Int] else {
            favButton.setBackgroundImage(UIImage(named: imageName), for: .normal)
            return
        }
        
        
        for id in favs {
            if id == marvelObject.id {
                imageName = "fav-full"
                isFav = true
            }
        }
        
        favButton.setBackgroundImage(UIImage(named: imageName), for: .normal)
    }
    
    @IBAction func favButtonTapped(_ sender: Any) {
        if UserDefaults.standard.array(forKey: "\(marvelObject.type.rawValue)FavId") == nil {
            UserDefaults.standard.set([marvelObject.id], forKey: "\(marvelObject.type.rawValue)FavId")
        }
        
        var favs = UserDefaults.standard.array(forKey: "\(marvelObject.type.rawValue)FavId") as! [Int]
        
        if isFav {
            let newFavs = favs.filter {$0 != marvelObject.id}
            UserDefaults.standard.set(newFavs, forKey: "\(marvelObject.type.rawValue)FavId")
            
            favButton.setBackgroundImage(UIImage(named: "fav-empty"), for: .normal)
        
        } else {
            favs.append(marvelObject.id)
            UserDefaults.standard.set(favs, forKey: "\(marvelObject.type.rawValue)FavId")
            
            favButton.setBackgroundImage(UIImage(named: "fav-full"), for: .normal)
        }
        
        isFav = !isFav
    }
    
    @IBAction func share() {
        let share: [Any] = [imageView.image!, "Uhhhh.. look whom I've found! Check \(marvelObject.name) out at MarvelApp!"]
        
        let activityViewController = UIActivityViewController(activityItems: share, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func saveImage(_ sender: Any) {
        if let image = preDownloadedImage {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            let ac = UIAlertController(title: "Saved", message: "Yesss.. From now on you can check this awesome \(marvelObject.type.rawValue.capitalizingFirstLetter())'s picture in your libarary! You're welcome.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Thanks", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Ups..", message: "Oh no .. seems like there was a problem while saving the picture. Maybe try another time?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
}

