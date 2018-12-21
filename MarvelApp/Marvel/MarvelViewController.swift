//
//  MarvelViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 14/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit

class MarvelViewController: UIViewController {
    
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var comicsContainer: UIView!
    @IBOutlet weak var charactersContainer: UIView!
    @IBOutlet weak var creatorsContainer: UIView!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    private var comicsController: MarvelCollectionViewController?
    private var charactersController: MarvelCollectionViewController?
    private var creatorsController: MarvelCollectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Marvel Database"
        setupLayout()
    }
    
    func activeContainer() -> MarvelCollectionViewController? {
        if !comicsContainer.isHidden {
            return comicsController
        } else if !charactersContainer.isHidden {
            return charactersController
        } else if !creatorsContainer.isHidden {
            return creatorsController
        }
        return nil
    }
    
    private func setupLayout() {
        
        segment.selectedSegmentIndex = 1 // characters
        hideContainersFor(comics: true, characters: false, creators: true)
        
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(view).offset(topbarHeight)
            make.left.right.equalTo(view)
            make.height.equalTo(60)
        }
        segmentView.backgroundColor = UIColor(white: 0.98, alpha: 1)
        segmentView.layer.borderColor = UIColor(white: 0.6, alpha: 1).cgColor
        segmentView.layer.borderWidth = 0.5
        
        segment.snp.makeConstraints { make in
            make.top.equalTo(segmentView).offset(15)
            make.left.right.equalTo(segmentView).inset(10)
        }
        
        comicsContainer.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }
        
        charactersContainer.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }
        
        creatorsContainer.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }
    }
    
    private func hideContainersFor(comics: Bool, characters: Bool, creators: Bool) {
        comicsContainer.isHidden = comics
        charactersContainer.isHidden = characters
        creatorsContainer.isHidden = creators
    }
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // comics
            hideContainersFor(comics: false, characters: true, creators: true)
        case 1:
            // characters
            hideContainersFor(comics: true, characters: false, creators: true)
        case 2:
            // creators
            hideContainersFor(comics: true, characters: true, creators: false)
        default:
            // default characters
            hideContainersFor(comics: true, characters: false, creators: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let collectionViewController = segue.destination as? MarvelCollectionViewController else {
            return
        }
        
        if segue.identifier == "ComicsSegue" {
            collectionViewController.marvelType = .comics
            comicsController = collectionViewController
        } else if segue.identifier == "CharactersSegue" {
            collectionViewController.marvelType = .characters
            charactersController = collectionViewController
        } else if segue.identifier == "CreatorsSegue" {
            collectionViewController.marvelType = .creators
            creatorsController = collectionViewController
        }
        
    }

    @IBAction func scrollToTop(_ sender: Any) {
        if let activeController = activeContainer() {
            activeController.collectionView.setContentOffset(.zero, animated: true)
        }
    }
}
