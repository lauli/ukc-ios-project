//
//  QuizViewController.swift
//  MarvelApp
//
//  Created by Laureen Schausberger on 20.12.18.
//  Copyright © 2018 Laureen Schausberger. All rights reserved.
//

import SnapKit
import UIKit

class QuizViewController: UIViewController {

    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!

    @IBOutlet weak var currentScoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    
    private let dataManager = DataManager.shared
    private var marvelObject: MarvelObject = MarvelObject(type: .characters, id: 0, name: "", thumbnail: "")
    private var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let highScore = UserDefaults.standard.integer(forKey: "highscore")
        if highScore > 0 {
            highScoreLabel.text = "High Score: \(highScore)"
        } else {
            highScoreLabel.isHidden = true
        }
        
        setupLayout()
        
        if dataManager.characters.isEmpty, dataManager.characters.count < 60 {
            self.selectRandomCharacter()
            dataManager.request(type: .characters, amountOfObjectsToRequest: 100) { _,_  in
               print("QuizViewController")
            }

        } else if dataManager.characters.isEmpty {
            dataManager.request(type: .characters, amountOfObjectsToRequest: 100) { _,_  in
                self.selectRandomCharacter()
            }

        } else {
            selectRandomCharacter()
        }
    }
    
    private func setupLayout() {
        
        currentScoreLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaInsets.bottom).offset(60)
            make.left.equalTo(view.safeAreaInsets.bottom).offset(20)
            make.right.equalTo(0)
        }
        
        highScoreLabel.snp.makeConstraints { make in
            make.top.right.equalTo(view).offset(20)
            make.left.equalTo(0)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(currentScoreLabel.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).inset(20)
            make.height.equalTo(view.bounds.height / 3 + 50)
        }
        imageView.backgroundColor = .gray
        
        questionLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).inset(20)
        }
        
        buttonView.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
        
        buttonA.snp.makeConstraints { make in
            make.top.left.equalTo(buttonView)
            make.width.equalTo(buttonView.bounds.width / 2 - 20)
            make.height.equalTo(buttonView.bounds.height / 2 - 20)
        }
        buttonA.backgroundColor = .red
        buttonA.layer.cornerRadius = 15
        
        buttonB.snp.makeConstraints { make in
            make.top.right.equalTo(buttonView)
            make.width.equalTo(buttonView.bounds.width / 2 - 20)
            make.height.equalTo(buttonView.bounds.height / 2 - 20)
        }
        buttonB.backgroundColor = .blue
        buttonB.layer.cornerRadius = 15
        
        buttonC.snp.makeConstraints { make in
            make.bottom.left.equalTo(buttonView)
            make.width.equalTo(buttonView.bounds.width / 2 - 20)
            make.height.equalTo(buttonView.bounds.height / 2 - 20)
        }
        buttonC.backgroundColor = .green
        buttonC.layer.cornerRadius = 15
        
        buttonD.snp.makeConstraints { make in
            make.bottom.right.equalTo(buttonView)
            make.width.equalTo(buttonView.bounds.width / 2 - 20)
            make.height.equalTo(buttonView.bounds.height / 2 - 20)
        }
        buttonD.backgroundColor = .yellow
        buttonD.layer.cornerRadius = 15
        
    }
    
    func selectRandomCharacter() {
        let index = Int.random(in: 0 ..< dataManager.characters.count)
        marvelObject = dataManager.characters[index]
        showPicture(forImageUrl: marvelObject.thumbnail ?? "")
        
        var array = [marvelObject.name]
        
        while (array.count < 4) {
            let index = Int.random(in: 0 ..< dataManager.characters.count)
            let newName = dataManager.characters[index].name
            if !array.contains(newName) {
                array.append(newName)
            }
        }
        
        setupButtons(byNames: array.shuffled())
    }
    
    private func setupButtons(byNames names: [String]) {
        buttonA.setTitle(names[0], for: .normal)
        buttonB.setTitle(names[1], for: .normal)
        buttonC.setTitle(names[2], for: .normal)
        buttonD.setTitle(names[3], for: .normal)
    }
    
    private func showPicture(forImageUrl url: String) {
        DataManager().requestImage(forImageUrl: url) { image, _ in
            DispatchQueue.main.async {
                if image != nil {
                    self.imageView.image = image
                }
            }
        }
    }
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == marvelObject.name {
            score = score + 100
        
        } else {
            score = score - 100
        }
        
        selectRandomCharacter()
        currentScoreLabel.text = "Your Score: \(score)"
        
        if dataManager.characters.count < 150 {
            dataManager.request(type: .characters, amountOfObjectsToRequest: 10) { _,_  in
                print("QuizViewController > Requested more.")
            }
        }
    }
    
}
