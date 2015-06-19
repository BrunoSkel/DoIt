//
//  ChallengeCompleteController.swift
//  DoIt
//
//  Created by Danilo S Marshall on 6/18/15.
//  Copyright (c) 2015 CoffeeTime. All rights reserved.
//

import UIKit


class ChallengeCompleteController: UIViewController {

    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var bgAddImage: UIImageView!
    @IBOutlet weak var challengeCompletedTxt: UITextView!
    var timelineController : TimelineController!
    
    var timelinePoint : TimelinePoint!
    
    var delegateTimeline : TimelineDelegate? = nil
    
    var challengeTag : Int = 99
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTimePoint(){
        timelinePoint.setSelectedChallenge(challengeTag)
        timelinePoint.changeState(PointState.Finished)
        delegateTimeline!.updateSelectedChallenge(timelinePoint.getDay(),chosenChallenge: challengeTag)
    }

    
    @IBAction func addImage(sender: AnyObject) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
