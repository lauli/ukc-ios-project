//
//  ViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 12/11/2018.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var tableViewContainer: UIView!
    
    
    @IBOutlet weak var informationView: UIView!

    
//    @IBOutlet weak var infoText: UILabel!
//
//    @IBOutlet weak var testView: UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        
        imageView.image = UIImage(named: "default")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        informationView.backgroundColor = .white
        tableViewContainer.backgroundColor = .white
//        testView.backgroundColor = .blue
//
//        let text = "name of superhero"
//        infoText.text = text + text + text
//        infoText.backgroundColor = .red
        
        imageContainer.backgroundColor = .darkGray
        
        scrollView.snp.makeConstraints { make in
            
            make.top.equalTo(view).offset(topbarHeight)
        }
        
        imageContainer.snp.makeConstraints { make in
            
            make.top.equalTo(scrollView)
            make.left.right.equalTo(view)
            make.height.equalTo(imageContainer.snp.width).multipliedBy(0.7)
        }
        
        imageView.snp.makeConstraints { make in
            
            make.left.right.equalTo(imageContainer)
            
            //** Note the priorities
            make.top.equalTo(view).priority(.high)
            
            //** We add a height constraint too
            make.height.greaterThanOrEqualTo(imageContainer.snp.height).priority(.required)
            
            //** And keep the bottom constraint
            make.bottom.equalTo(imageContainer.snp.bottom)
        }
        
        informationView.snp.makeConstraints { make in
            make.left.right.equalTo(scrollView)
            make.top.equalTo(imageContainer.snp.bottom)
            make.bottom.equalTo(scrollView)
        }
        
//        infoText.snp.makeConstraints { make in
//            make.left.right.equalTo(scrollView)
//            make.top.equalTo(informationView).inset(10)
//        }
//
        tableViewContainer.snp.makeConstraints { make in
            make.left.right.top.equalTo(scrollView)
//            make.top.equalTo(infoText.snp.bottom)
        }
        
//        testView.snp.makeConstraints { make in
//            make.left.right.equalTo(scrollView)
//            make.top.equalTo(infoText.snp.bottom)
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.scrollIndicatorInsets = view.safeAreaInsets
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0,
                                               bottom: view.safeAreaInsets.bottom, right: 0)
    }

}


