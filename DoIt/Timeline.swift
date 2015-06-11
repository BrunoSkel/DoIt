//
//  ViewController.swift
//  DoIt
//
//  Created by Danilo S Marshall on 6/10/15.
//  Copyright (c) 2015 CoffeeTime. All rights reserved.
//

import UIKit

class Timeline: UIViewController,UIPopoverPresentationControllerDelegate {
    @IBOutlet var timelineScroll: UIScrollView!
    @IBOutlet var defaultTimelinebutton: TimelinePoint!
    @IBOutlet var timelineAnchor: UIView!
    var pointsNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTimeLineData()
        
    }
    
    func loadTimeLineData(){
        //TODO: Pull data from the server. Loading fake data for now
        
        //Supposed server array ordenation: currentday-yesterday-the day before-and it goes
        
        loadFakeData()
        
        //Making points=========
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        var x:CGFloat=screenSize.width/2-20
        let y:CGFloat=screenSize.height-60
        timelineScroll.frame = self.view.frame
        timelineAnchor.frame = CGRectMake(x+20, y-80, 1, 1)
        //Create Locked points
        
        for var j=0; j<3; j++
        {
            var newPoint = TimelinePoint(nil)
            // newPoint = defaultTimelinebutton
            newPoint.frame = CGRectMake(x+70, y, 40, 40)
            newPoint.changeState(PointState.Locked)
            self.view.addSubview(newPoint)
            
            x+=70;
            
        }
        
        //And the unlocked points
        
        x=screenSize.width/2-20
        for var i=pointsNumber; i>0; i--
        {
            var newPoint = TimelinePoint(nil)
           // newPoint = defaultTimelinebutton
            newPoint.frame = CGRectMake(x, y, 40, 40)
            newPoint.changeState(PointState.Unfinished)
            self.view.addSubview(newPoint)
            newPoint.addTarget(self, action: "timelineButTouched:", forControlEvents: UIControlEvents.TouchUpInside)
            
            x-=70;
            
        }
        //=======================
        
        defaultTimelinebutton.hidden=true
        
    }

    @IBAction func timelineGoLeft(sender: AnyObject) {
    }
    
    @IBAction func timelineButTouched(sender: AnyObject) {
        //Show PopOver
        let popOverController=self.storyboard!.instantiateViewControllerWithIdentifier("PopOverDefault") as! PopOverController
        popOverController.modalPresentationStyle = .Popover
        popOverController.preferredContentSize = CGSizeMake(300, 400)
        
        let popOverPresentation = popOverController.popoverPresentationController
        popOverPresentation?.permittedArrowDirections = .Any
        popOverPresentation?.delegate = self
        popOverPresentation?.sourceView = timelineAnchor
        presentViewController(popOverController, animated: true, completion: nil)
    }
    
    //Popover Delegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle{
        return .None
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadFakeData(){
                pointsNumber = 15;
    }
    

}

