//
//  PopOverController.swift
//  DoIt
//
//  Created by Bruno Henrique da Rocha e Silva on 6/11/15.
//  Copyright (c) 2015 CoffeeTime. All rights reserved.
//

import UIKit


class PopOverController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var challenge1: UIButton!
    @IBOutlet weak var challenge2: UIButton!
    @IBOutlet weak var doneChallenge: UIButton!
    
    @IBOutlet weak var lbOr: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    
    var timelineViewController : TimelineController!
    
    var timelinePoint : TimelinePoint!
    
    var delegateTimeline : TimelineDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ShowLoadingIndicator(bool : Bool){
        lbOr.hidden = bool
        challenge1.hidden = bool
        challenge2.hidden = bool
        doneChallenge.hidden = true
        
        activityIndicator.hidden = !bool
        
        if(bool){
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
        }
    }
    
    func ShowChallenges() {
        lbTitle.text = "Today, you could..."
        lbOr.hidden = false
        challenge1.hidden = false
        challenge2.hidden = false
        doneChallenge.hidden = true
    }
    
    func ShowChallengeComplete() {
        lbTitle.text = "You've completed today's challenge"
        
        lbOr.hidden = true
        challenge1.hidden = true
        challenge2.hidden = true
        doneChallenge.hidden = false
        doneChallenge.setTitle("Check your challenge info", forState: .Normal)
        
    }

    
    @IBAction func ChallengeAccomplished(sender: AnyObject) {
        timelineViewController.isChangingChoice = true
        

        timelinePoint.setSelectedChallenge(sender.tag)
        timelinePoint.changeState(PointState.Finished)
        
        
        delegateTimeline!.updateSelectedChallenge(timelinePoint.getDay(),chosenChallenge: sender.tag)
        
        
        dismissViewControllerAnimated(false, completion: nil)
        timelineViewController.performSegueWithIdentifier("GoToCompleteChallenge", sender: timelineViewController)
    }
    
    @IBAction func SeeGlobalStats(sender: AnyObject) {
        timelineViewController.isChangingChoice = false
        
        dismissViewControllerAnimated(false, completion: nil)
        timelineViewController.performSegueWithIdentifier("GoToGlobalStats", sender: timelineViewController)
    }

    @IBAction func CloseButton(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func ChangeCompleteStats(sender: AnyObject) {
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "GoToCompleteChallenge") {
            let nextVC = (segue.destinationViewController as! ChallengeCompleteController)
            nextVC.timelinePoint = timelinePoint
        }
    }
}