//
//  TimelinePoint.swift
//  DoIt
//
//  Created by Danilo S Marshall on 6/10/15.
//  Copyright (c) 2015 CoffeeTime. All rights reserved.
//

//import Foundation
import UIKit

public enum PointState {
    case Locked
    case Unfinished
    case Finished
}

enum ShareState : Int {
    case Facebook = 1
    case Instagram = 2
    case Twitter = 4
}


class TimelinePoint : UIView {
    
    var button:UIButton!
    var month:UILabel!
    var day:UILabel!
    
    private let unfineshedChallengeImg = UIImage(named:"TimelineBtn_empty")
    private let finishedChallengeImg = UIImage(named:"TimelineBtn_filled")
    let lockedChallengeImg = UIImage(named:"TimelineBtn_inactive")
    
    public var currentState : PointState = PointState.Locked
    
    private var currentDay : Int!
    private var currentDate : NSDate!
    private var challenge : [String]!
    
    private var challengeCompletePicture : UIImage!
    private var challengeCompleteText : String!
    private var shared : Int!

    // MARK: - Initializers and Setters
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        currentState = PointState.Locked
        currentDate = NSDate()
        currentDay = 0
        challenge = ["",""]
        shared = 0
        self.hidden=false
        println("Point Created")
        //self.backgroundColor=UIColor.redColor()
        self.createSubViews()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setInitialData (cDay : Int, cDate : NSDate, challengeA : String, challengeB : String) {
        currentDay = cDay
        currentDate = cDate
        challenge = [challengeA,challengeB]
    }
    
    func setPicture (pic : UIImage) {
        challengeCompletePicture = pic
    }
    
    func setText (txt : String) {
        challengeCompleteText = txt
    }
    
    // MARK: - Getter Methods
    func getPicture () -> UIImage {
        return challengeCompletePicture
    }
    
    func getText () -> String {
        return challengeCompleteText
    }
    
    func getChallenges () -> [String] {
        return challenge
    }
    
    func getSharedState () -> Int {
        return shared
    }
    
    func getState () -> PointState {
        return currentState
    }
    
    
    // MARK: - Public Methods
    
    func changeState(state : PointState) {
        currentState = state
        updateState()
    }
    
    func shareChallenge (shareLocation : ShareState) {
        switch shareLocation {
        case ShareState.Facebook:
            if(self.shared == 1 || self.shared == 3 || self.shared == 5 || self.shared == 7) {
                println("Challenged was already shared on Facebook")
            }
            else {
                self.shared = self.shared + 1
                
                // TODO: Add methods from connection manager to share data
            }
        case ShareState.Instagram:
            if(self.shared == 2 || self.shared == 3 || self.shared == 6 || self.shared == 7) {
                println("Challenged was already shared on Instagram")
            }
            else {
                self.shared = self.shared + 2
                
                // TODO: Add methods from connection manager to share data
            }
        case ShareState.Twitter:
            if(self.shared == 4 || self.shared == 5 || self.shared == 6 || self.shared == 7) {
                println("Challenged was already shared on Twitter")
            }
            else {
                self.shared = self.shared + 4
                
                // TODO: Add methods from connection manager to share data
            }
        default:
            println("Need to select an option form ShareState to be able to share")
        }
    }
    
    func UpdateDateLabel(monthL : String, dayL : String){
        day.text=dayL
        month.text=monthL
    }
    
    // MARK: - Private Methods
    
    func createSubViews() {
        //
        var newButton = UIButton(frame: CGRectMake(0, 0, 45, 45))
        newButton.setTitle("", forState: UIControlState.Normal)
        newButton.setBackgroundImage(self.unfineshedChallengeImg, forState: UIControlState.Normal)
        button=newButton
        self.addSubview(newButton) // assuming you're in a view controller
        //
        var monthLabel = UILabel(frame: CGRectMake(6, 8, 33, 21))
        monthLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 12.0)
        monthLabel.textAlignment = NSTextAlignment.Center
        monthLabel.text = "JAN"
        month=monthLabel
        self.addSubview(monthLabel)
        //
        //
        var dayLabel = UILabel(frame: CGRectMake(6, 19, 33, 21))
        dayLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 12.0)
        dayLabel.textAlignment = NSTextAlignment.Center
        dayLabel.text = "30"
        day=dayLabel
        self.addSubview(dayLabel)
        //
        self.hidden=false
    }
    
    private func updateState () {
        switch currentState {
        case PointState.Locked:
            button.setImage(self.lockedChallengeImg, forState: UIControlState.Normal)
        case PointState.Unfinished:
            button.setImage(self.unfineshedChallengeImg, forState: .Normal)
        case PointState.Finished:
            button.setImage(self.finishedChallengeImg, forState: .Normal)
        default:
            button.setImage(self.lockedChallengeImg, forState: .Normal)
        }
    }
    
}