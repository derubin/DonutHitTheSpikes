//
//  GameOver.swift
//  DonutHitTheSpikes
//
//  Created by Daniel Rubin on 7/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class GameOver: CCNode {
    
    weak var scoreLabel: CCLabelTTF!
    weak var highscoreLabel: CCLabelTTF!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func setMessage(score: Int) {
        scoreLabel.string = "\(score)"
    }
    
    func startAgain() {
        let gameplayScene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().presentScene(gameplayScene)
    }
    
    func updateHighscore() {
        var newHighscore = defaults.integerForKey("highscore")
        highscoreLabel.string = "\(newHighscore)"
    }
    
//    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
//        if keyPath == "highscore" {
//            updateHighscore()
//        }
//    }
    
}