import Foundation

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    
    weak var donut: Donut!
    weak var donutPhysics: CCPhysicsNode!
    weak var pauseNode: CCNodeColor!
    weak var gameScore: CCLabelTTF!
    var endGame = 0 //adds value when game is over to stop touchBegan
    var howMany = 0 //how many times the screen was tapped, the score
    var onlyOnce = 0 //activates end game only once
    var untilWind = 0 //counts up once per frameto randomWind
    var randomWind = 180 //random int between 150 to 300
    var tutorialGone = 1 //removes the tutorial after one tap
    var tutorialPopover = CCBReader.load("Tutorial") as! Tutorial
    var randomType = Int(arc4random_uniform(4))
    var windBlown = false
    var endPos = CGPoint(x: 0, y: 0)
    var leftWeak = -200
    var leftStrong = -300
    var rightWeak = 200
    var rightStrong = 300
    
    let defaults = NSUserDefaults.standardUserDefaults()

    func didLoadFromCCB() {
        userInteractionEnabled = true
        donutPhysics.collisionDelegate = self
        addChild(tutorialPopover)
        tutorialPopover.contentSize = CGSize(width: CCDirector.sharedDirector().viewSize().width, height: CCDirector.sharedDirector().viewSize().height)
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if self.paused == true {
            pauseGame()
            return
        }
        if endGame >= 1 {
            return
        }
        
        if tutorialGone == 1 {
            tutorialGone = 0
            tutorialPopover.removeFromParent()
        }
        
        var xTouch = touch.locationInWorld().x
        var screenSeg = CCDirector.sharedDirector().viewSize().width / 5
        if xTouch < screenSeg {
            //println("Left")
            donut.physicsBody.applyImpulse(CGPoint(x: -125, y: 0))
        }
        else if xTouch > (screenSeg * 4) {
            //println("Right")
            donut.physicsBody.applyImpulse(CGPoint(x: 125, y: 0))
        }
        else {
            //println("Up")
            donut.physicsBody.applyImpulse(CGPoint(x: 0, y: 300))
        }
        howMany++
        
        rightWeak = rightWeak + 5
        leftWeak = leftWeak - 5
        rightStrong = rightStrong + 5
        leftStrong = leftStrong - 5
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, frosting: Donut!, wildcard: CCNode!) {
        gameOver()
    }
    
    override func fixedUpdate(delta: CCTime) {
        if endGame == 0 {
            if untilWind > (randomWind - 50) && windBlown == false {
                if randomType == 0 || randomType == 1 {
                    let explosion = CCBReader.load("WindLeft") as! CCParticleSystem
                    explosion.position = CGPoint(x: 0, y: (CCDirector.sharedDirector().viewSize().height / 2))
                    explosion.autoRemoveOnFinish = true
                    donutPhysics.addChild(explosion)
                }
                else if randomType == 2 || randomType == 3 {
                    let explosion = CCBReader.load("WindRight") as! CCParticleSystem
                    explosion.position = CGPoint(x: CCDirector.sharedDirector().viewSize().width, y: (CCDirector.sharedDirector().viewSize().height / 2))
                    explosion.autoRemoveOnFinish = true
                    donutPhysics.addChild(explosion)
                }
                windBlown = true
            }
            if untilWind > randomWind {
                if randomType == 0 {
                    donut.physicsBody.applyImpulse(CGPoint(x: rightWeak, y: 0))
                }
                if randomType == 1 {
                    donut.physicsBody.applyImpulse(CGPoint(x: rightStrong, y: 0))
                }
                if randomType == 2 {
                    donut.physicsBody.applyImpulse(CGPoint(x: leftWeak, y: 0))
                }
                if randomType == 3 {
                    donut.physicsBody.applyImpulse(CGPoint(x: leftStrong, y: 0))
                }
                randomType = Int(arc4random_uniform(4))
                untilWind = 0
                randomWind = (Int(arc4random_uniform(60)) + 120)
                windBlown = false
            }
            untilWind++
        }
    }
    
    func donutGone() {
        let explosion = CCBReader.load("Explosion") as! CCParticleSystem
        explosion.autoRemoveOnFinish = true
        var xPos = CCDirector.sharedDirector().viewSize().width * donut.position.x
        var yPos = CCDirector.sharedDirector().viewSize().height * donut.position.y
        explosion.position = CGPoint(x: xPos, y: yPos)
        donutPhysics.addChild(explosion)
        donut.removeFromParent()
    }
    
    func gameOver() {
        if tutorialGone == 1 {
            tutorialGone = 0
            tutorialPopover.removeFromParent()
        }
        
        if onlyOnce == 0 {
            endGame++
            onlyOnce++
            donutGone()
            var gameEndPopover = CCBReader.load("GameOver") as! GameOver
            gameEndPopover.setMessage(howMany)
            addChild(gameEndPopover)
            gameEndPopover.contentSize = CGSize(width: CCDirector.sharedDirector().viewSize().width, height: CCDirector.sharedDirector().viewSize().height)
            
            var highscore = defaults.integerForKey("highscore")
            if howMany > highscore {
                defaults.setInteger(howMany, forKey: "highscore")
            }
            gameEndPopover.updateHighscore()
        }
    }
    
    func pauseGame() {
        if self.paused == false && endGame == 0 {
            if tutorialPopover.visible == true {
                tutorialPopover.visible = false
            }
            self.paused = true
            endGame++
            pauseNode.visible = true
            gameScore.string = "\(howMany)"
        }
        else if self.paused == true {
            if tutorialGone == 1 {
                tutorialPopover.visible = true
            }
            self.paused = false
            endGame = 0
            pauseNode.visible = false
        }
    }
}
