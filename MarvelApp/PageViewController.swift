//
//  PageViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 14/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {
    
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var comicsContainer: UIView!
    @IBOutlet weak var charactersContainer: UIView!
    @IBOutlet weak var creatorsContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    private func setupLayout() {
        
        segment.selectedSegmentIndex = 1 // characters
        hideContainersFor(comics: true, characters: false, creators: true)
        
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(view).offset(topbarHeight)
            make.left.right.equalTo(view)
            make.height.equalTo(40)
        }
        
        segment.snp.makeConstraints { make in
            make.top.left.right.equalTo(segmentView).inset(5)
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
        guard let collectionViewController = segue.destination as? CollectionViewController else {
            return
        }
        
        if segue.identifier == "ComicsSegue" {
            collectionViewController.marvelType = .comics
        } else if segue.identifier == "CharactersSegue" {
            collectionViewController.marvelType = .characters
        } else if segue.identifier == "CreatorsSegue" {
            collectionViewController.marvelType = .creators
        }
        
    }

}
