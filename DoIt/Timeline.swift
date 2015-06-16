//
//  ViewController.swift
//  DoIt
//
//  Created by Danilo S Marshall on 6/10/15.
//  Copyright (c) 2015 CoffeeTime. All rights reserved.
//

import UIKit

class Timeline: UIViewController,UIPopoverPresentationControllerDelegate {
    @IBOutlet var defaultTimelinebutton: TimelinePoint!
    var timelineScroll:UIScrollView!
    var timelineAnchor: UIView!
    var pointsArray:NSMutableArray!
    
    var selectedTimelinePoint : TimelinePoint!
    var isChangingChoice = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.setTranslatesAutoresizingMaskIntoConstraints(true)
        loadTimeLineData()
        
    }
    
    func loadTimeLineData(){
        //TODO: Pull data from the server. Loading fake data for now
        
        //Supposed server array ordenation: 1stday-2ndday-3rdday and it goes
        
        loadFakeData()
        
        //Making points=========
        let screenSize: CGRect = UIScreen.mainScreen().bounds
      //  var x:CGFloat=screenSize.width/2-20
        let y:CGFloat=screenSize.height-60
        
        let scrollInitialX:CGFloat = self.view.frame.width
        let pointsNumber = CGFloat(pointsArray.count)
        let scrollWidth = ((defaultTimelinebutton.frame.width+30)*(pointsNumber+3))
        timelineScroll = UIScrollView(frame: CGRectMake(0, y, self.view.frame.width, 120))
        var x:CGFloat=scrollWidth-defaultTimelinebutton.frame.width
        
        timelineScroll.contentSize = CGSizeMake(scrollWidth, 120);
        
        
        self.view.addSubview(timelineScroll)
        
        
        timelineAnchor = UIView(frame: CGRectMake(screenSize.width/2, y-40, 1, 1))
        
        self.view.addSubview(timelineAnchor)
        
        //Create Locked points
        
        for var j=0; j<3; j++
        {
            var newPoint:TimelinePoint = TimelinePoint(frame: CGRectMake(0, 0, 45, 45), cDay: j, cDate: NSDate(), chlg: ["",""])
            // newPoint = defaultTimelinebutton
            newPoint.frame = CGRectMake(x, 0, 45, 45)
            newPoint.changeState(PointState.Locked)
            newPoint.UpdateDateLabel("",dayL: "")
            timelineScroll.addSubview(newPoint)
            
            x-=70;
            
        }
        
        //And the unlocked points
        
        x=scrollWidth-40 - (70*3) //3=locked points number
        for var i=pointsArray.count; i>0; i--
        {
            var newPoint:TimelinePoint = TimelinePoint(frame: CGRectMake(90, 40, 45, 45), cDay: i, cDate: NSDate(), chlg: ["",""])
            //var newPoint:TimelinePoint = TimelinePoint(frame: CGRectMake(90, 40, 45, 45))
            // newPoint = defaultTimelinebutton
            newPoint.frame = CGRectMake(x, 0, 45, 45)
            newPoint.changeState(PointState.Unfinished)
            timelineScroll.addSubview(newPoint)
            newPoint.button.addTarget(self, action: "timelineButTouched:", forControlEvents: UIControlEvents.TouchUpInside)
            
            let month:String = self.pointsArray[i-1][0] as! String
            let day:String = self.pointsArray[i-1][1] as! String
            newPoint.UpdateDateLabel(month, dayL: day)
            x-=70;
            
            if (i==pointsArray.count){
                CenterTimelineAt(newPoint.button)
            }
            
        }
        //=======================
        
        defaultTimelinebutton.hidden=true
        
    }

    func CenterTimelineAt(sender: AnyObject) {
        
        //Not sure why it returns the position of the object 2 times ahead of it, so I reduce it by 2x
        
        let frame = sender.convertPoint(sender.frame.origin, toView: timelineScroll)
        println(frame.x)
        let newOffset = CGPointMake(frame.x-(self.view.frame.size.width / 2)+22, 0);
        timelineScroll.setContentOffset(newOffset, animated: true)
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
        
        LoadPointData(popOverController,timelinePoint: sender.superview as! TimelinePoint)
        
        CenterTimelineAt(sender)

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
        pointsArray=NSMutableArray()
        
        for var p=0; p<15; p++ {
            self.pointsArray.insertObject(NSMutableArray(), atIndex: p)
            self.pointsArray[p].insertObject("MAR", atIndex: 0)
            self.pointsArray[p].insertObject("1", atIndex: 1)
            self.pointsArray[p].insertObject("Draw Something", atIndex: 2)
            self.pointsArray[p].insertObject("Exercise", atIndex: 3)
        }
        
        //TO DO: Montar timeline com vetor de TimelinePoint a partir do dia atual do servidor
        
        //GetServerCurrentDayNumberAndDate tem retorno duplo, um NSInteger e um NSDate
        var (currentDayNumber : NSInteger,currentDate : NSDate) = ServerConnection.sharedInstance.GetServerCurrentDayNumberAndDate()
        println(currentDayNumber)
        println(currentDate)
    }

    func LoadPointData(popOverController : PopOverController, timelinePoint : TimelinePoint){
        
        let dayNumber = 1 //TODO: Definir o numero de dia aqui quando o vetor estiver implementado
        let langId = 0 //TODO: Definir o id do idioma aqui quando o suporte a multilinguas estiver implementado, 0=en 1=pt
        let pointDate : NSDate = NSDate() //TODO: Definir o NSDate do botao aqui quando o vetor estiver implementado

        selectedTimelinePoint = timelinePoint

        popOverController.timelineViewController = self
        popOverController.timelinePoint = timelinePoint
        
        //Load a day challenge GetChallenges(dayNumber, langId 0=en, 1=pt)
        let dayChallengesArray = ServerConnection.sharedInstance.GetChallenges(dayNumber, lang: langId) as! [String]
        
        let strChallenge1 = dayChallengesArray[0]
        let strChallenge2 = dayChallengesArray[1]
        
        //Init Data for timeline point
        timelinePoint.setInitialData(dayNumber, cDate: pointDate, chlg: dayChallengesArray)
        
        popOverController.challenge1.setTitle(strChallenge1, forState: .Normal)
        popOverController.challenge2.setTitle(strChallenge2, forState: .Normal)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "GoToGlobalStats"){
            let globalStatsController = segue.destinationViewController as! GlobalStatsController
            
            globalStatsController.selectedTimelinePoint = selectedTimelinePoint
            globalStatsController.changeChoice = isChangingChoice
        }
    }
    

}

