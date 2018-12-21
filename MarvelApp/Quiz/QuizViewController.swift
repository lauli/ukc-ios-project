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
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
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
    private var oldHighScore = 0
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let highScore = UserDefaults.standard.integer(forKey: "highscore")
        if highScore > 0 {
            highScoreLabel.text = "High Score: \(highScore)"
            oldHighScore = highScore
        } else {
            highScoreLabel.text = "High Score: 0"
        }
        
        currentScoreLabel.text = "Your Score: 0"

        setupLayout()
        loading(true)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.dataManager.characters.count >= 10 {
                self.timer?.invalidate()
                self.timer = nil
                self.selectRandomCharacter()
            }
        }
    }
    
    private func loading(_ hide: Bool) {
        if hide {
            indicatorView.startAnimating()
        } else {
            indicatorView.stopAnimating()
        }
        
        imageView.isHidden = hide
        buttonView.isHidden = hide
        questionLabel.isHidden = hide
    }
    
    private func setupLayout() {
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "quiz-background")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        currentScoreLabel.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(0)
        }
        currentScoreLabel.textColor = .black
        
        highScoreLabel.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.right.equalTo(view).inset(20)
            make.left.equalTo(0)
        }
        highScoreLabel.textColor = .black
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(currentScoreLabel.snp.bottom).offset(20)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(view.bounds.height / 3 + 50)
        }
        imageView.backgroundColor = .gray
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor(white: 0, alpha: 1).cgColor
        
        questionLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).inset(20)
        }
        questionLabel.textColor = .black
        
        buttonView.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(20)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
        buttonView.backgroundColor = .clear
        setupButtonLayout()
    }
    
    private func setupButtonLayout() {
        setupButtonLayout(forButton: buttonA, position: 0)
        setupButtonLayout(forButton: buttonB, position: 1)
        setupButtonLayout(forButton: buttonC, position: 2)
        setupButtonLayout(forButton: buttonD, position: 3)
        
    }
    
    private func setupButtonLayout(forButton button: UIButton, position: Int) {
        button.snp.makeConstraints { make in
            make.width.equalTo(buttonView.bounds.width / 2 - 30)
            make.height.equalTo(buttonView.bounds.height / 2 - 30)
            
            switch position {
            case 0:
                make.top.left.equalTo(buttonView)
            case 1:
                make.top.right.equalTo(buttonView)
            case 2:
                make.bottom.left.equalTo(buttonView)
            default:
                make.bottom.right.equalTo(buttonView)
            }
        }
        button.layer.cornerRadius = 15
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .clear
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(white: 0, alpha: 1).cgColor
        
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.numberOfLines = 0
    }
    
    private func setupButtons(byNames names: [String]) {
        buttonA.setTitle(names[0], for: .normal)
        buttonB.setTitle(names[1], for: .normal)
        buttonC.setTitle(names[2], for: .normal)
        buttonD.setTitle(names[3], for: .normal)
    }
    
    private func showPicture(forImageUrl url: String) {
        dataManager.requestImage(forImageUrl: url) { image, _ in
            DispatchQueue.main.async {
                if image != nil {
                    self.imageView.image = image
                    self.loading(false)
                }
            }
        }
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
        
        DispatchQueue.main.async {
            self.setupButtons(byNames: array.shuffled())
        }
    }
    
    private func updateScores() {
        currentScoreLabel.text = "Your Score: \(score)"
        if oldHighScore <= score {
            UserDefaults.standard.set(score, forKey: "highscore")
        }
    }
    
    private func resetGame() {
        let message: String
        
        if oldHighScore > score {
            message = "\nYou missed the highscore by \(oldHighScore-score). Better luck next time."
        } else if oldHighScore == score {
            message = "\nUff, so close - but yet so far. Better luck next time."
        } else {
            message = "\nBut congratulations - you beat the highscore by \(score-oldHighScore)! \nWohoooooo!"
            highScoreLabel.text = "High Score: \(score)"
        }
        let alertController = UIAlertController(title: "Game Over",
                                                message: "Ups, seems like this was wrong ;) The correct answer was \(marvelObject.name). \(message)",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
            print("QuizViewController > User has pressed ok on alertcontroller to accept his/her defeat.")
            self.loading(true)
            self.selectRandomCharacter()
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
        
        score = 0
        currentScoreLabel.text = "Your Score: 0"
    }
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == marvelObject.name {
            score = score + 100
            
        } else {
            resetGame()
            return
        }
        updateScores()
        loading(true)
        
        selectRandomCharacter()
        
        guard let navigationController = tabBarController?.viewControllers?[1] as? UINavigationController,
        let marvelDataViewController = navigationController.topViewController as? MarvelViewController,
            let marvelCollectionVC = marvelDataViewController.activeContainer() else {
            return
        }
        
        if !marvelCollectionVC.isFetchInProgress, dataManager.characters.count < 150 {
            dataManager.request(type: .characters, amountOfObjectsToRequest: 50) { _,_  in
                print("QuizViewController > Requested more.")
            }
        }
    }
    
}
