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
    
    @IBOutlet weak var lbOr: UILabel!
    
    var timelineViewController : Timeline!
    
    var timelinePoint : TimelinePoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ShowLoadingIndicator(bool : Bool){
        lbOr.hidden = bool
        challenge1.hidden = bool
        challenge2.hidden = bool
        
        activityIndicator.hidden = !bool
        
        if(bool){
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
        }
    }

    
    @IBAction func ChallengeAccomplished(sender: AnyObject) {
        timelineViewController.isChangingChoice = true
        
        dismissViewControllerAnimated(false, completion: nil)
        timelineViewController.performSegueWithIdentifier("GoToGlobalStats", sender: timelineViewController)

        timelinePoint.setSelectedChallenge(sender.tag)
    }
    
    @IBAction func SeeGlobalStats(sender: AnyObject) {
        timelineViewController.isChangingChoice = false
        
        dismissViewControllerAnimated(false, completion: nil)
        timelineViewController.performSegueWithIdentifier("GoToGlobalStats", sender: timelineViewController)
    }

    @IBAction func CloseButton(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
}