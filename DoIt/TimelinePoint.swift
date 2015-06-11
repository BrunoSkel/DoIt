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

@IBDesignable class TimelinePoint : UIButton {
    
    private let unfineshedChallengeImg = UIImage(named:"TimelineBtn_empty")
    private let finishedChallengeImg = UIImage(named:"TimelineBtn_filled")
    let lockedChallengeImg = UIImage(named:"TimelineBtn_inactive")
    
    @IBInspectable var currentState : PointState = PointState.Locked {
        didSet {
            updateLayerProperties()
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()

        updateLayerProperties()
    }
    
    private func updateLayerProperties () {
        
    switch currentState {
    case PointState.Locked:
        setImage(self.lockedChallengeImg, forState: .Normal)
    case PointState.Unfinished:
        setImage(self.unfineshedChallengeImg, forState: .Normal)
    case PointState.Finished:
        setImage(self.finishedChallengeImg, forState: .Normal)
    default:
        setImage(self.lockedChallengeImg, forState: .Normal)
    }
        
    }
    
}