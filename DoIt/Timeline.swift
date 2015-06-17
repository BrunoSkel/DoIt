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
    
    @IBOutlet var doneChallengesLabel: UILabel!
    
    var timelineView : UIView!
    var timelineScroll : UIScrollView!
    var timelineAnchor : UIView!
    var pointsArray : NSMutableArray!
    var pointsArray2 : NSMutableArray!
    
    var doneChallengesInt : Int=0
    
    var selectedTimelinePoint : TimelinePoint!
    var isChangingChoice = false
    
    
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineView=UIView(frame: self.view.frame)
        
        timelineView.setTranslatesAutoresizingMaskIntoConstraints(true)
        
        self.view.addSubview(timelineView)
        
        loadTimeLineData()
        
    }
    
    func loadTimeLineData(){
        //TODO: Pull data from the server. Loading fake data for now
        
        //Supposed server array ordenation: 1stday-2ndday-3rdday and it goes
        
        loadFakeData()
        loadData()
        
        //Making points=========
        doneChallengesInt=0
        let screenSize: CGRect = UIScreen.mainScreen().bounds
      //  var x:CGFloat=screenSize.width/2-20
        let y:CGFloat=screenSize.height-60
        
        let scrollInitialX:CGFloat = self.view.frame.width
        let pointsNumber = CGFloat(pointsArray2.count)
        let scrollWidth = ((defaultTimelinebutton.frame.width+30)*(pointsNumber+3))
        timelineScroll = UIScrollView(frame: CGRectMake(0, y, self.view.frame.width, 120))
        var x:CGFloat=scrollWidth-defaultTimelinebutton.frame.width
        
        timelineScroll.contentSize = CGSizeMake(scrollWidth, 120);
        
        
        timelineView.addSubview(timelineScroll)
        
        
        timelineAnchor = UIView(frame: CGRectMake(screenSize.width/2, y-10, 1, 1))
        
        timelineView.addSubview(timelineAnchor)
        
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
        for var i=pointsArray2.count-1; i>=0; i--
        {
            let date : NSDate = pointsArray2[i][2] as! NSDate
            let calendar : NSCalendar = NSCalendar.currentCalendar()
            let components = calendar.components(.CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
            
            var newPoint:TimelinePoint = TimelinePoint(frame: CGRectMake(90, 40, 45, 45), cDay: pointsArray2[i][1] as! Int, cDate: date, chlg: pointsArray2[i][3] as! [String])
            //var newPoint:TimelinePoint = TimelinePoint(frame: CGRectMake(90, 40, 45, 45))
            // newPoint = defaultTimelinebutton
            newPoint.frame = CGRectMake(x, 0, 45, 45)
            //newPoint.changeState(PointState.Unfinished)
            timelineScroll.addSubview(newPoint)
            newPoint.button.addTarget(self, action: "timelineButTouched:", forControlEvents: UIControlEvents.TouchUpInside)
            
            let month : String = String(components.month)
            let day : String = String(components.day)
            
            //let month:String = self.pointsArray[i-1][0] as! String
            //let day:String = self.pointsArray[i-1][1] as! String
            newPoint.UpdateDateLabel(month, dayL: day)
            x-=70;
            
            //Update complete challenge's number
            if (newPoint.getState() == PointState.Finished){
                
                doneChallengesInt++
                
            }
            
            //Center onto the current day's button
            if (i == (pointsArray2.count-1)){
                CenterTimelineAt(newPoint.button)
                if (newPoint.getState() == PointState.Finished){
                }
                //!= not working?
                else{
                   self.timelineButTouched(newPoint.button)
                }
            }
            
        }
        //=======================
        
        defaultTimelinebutton.hidden=true
        doneChallengesLabel.text = String(doneChallengesInt)
        
    }

    func CenterTimelineAt(sender: AnyObject) {
        
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
    
    func loadData() {
        //check if there is any saved Data
        if var hasSaved = defaults.stringForKey("hasSaved") as String! {
            // has saved, get data
            if(hasSaved == "false") {
                println("hasSaved is false - Create new Data")
                createData()
            }
            else {
                println("hasSaved is true - Fetch Data")
                pointsArray2 = defaults.objectForKey("pointsArray") as! NSMutableArray
                
                // TODO: check current day of server and add missing days from saved Data
                addData()
            }
        }
        else {
            // haven't saved yet, need to create objects
            println("hasSaved don't exist - Create new Data")
            
            createData()
        }
        
        println("Array: \(pointsArray2)")
        saveData()
    }
    
    func addData() {
        //GetServerCurrentDayNumberAndDate tem retorno duplo, um NSInteger e um NSDate
        var (currentDayNumber : NSInteger,currentDate : NSDate) = ServerConnection.sharedInstance.GetServerCurrentDayNumberAndDate()
        
        let lastSavedDay = pointsArray2[pointsArray2.count-1][1] as! Int
        
        if(currentDayNumber == lastSavedDay) {
            // Number of timelinePoints is up to date
            println("timelinePoint array is up to date")
        }
        else {
            println("timelinePoint array is missing \(currentDayNumber - lastSavedDay) days")
            
            
            //Load a day challenge GetChallenges(dayNumber, langId 0=en, 1=pt)
            var langId = 1
            var dayChallengesArray = ServerConnection.sharedInstance.GetChallenges(currentDayNumber, lang: langId) as! [String]
            
            for var numDay = lastSavedDay; numDay < currentDayNumber; numDay++ {
                pointsArray2.insertObject(NSMutableArray(), atIndex: numDay)
                pointsArray2[numDay].insertObject(PointState.Unfinished.rawValue, atIndex: 0) // challengeState
                pointsArray2[numDay].insertObject(numDay+1, atIndex: 1) // challengeGlobalDay
                
                
                let calendar : NSCalendar = NSCalendar.currentCalendar()
                let relativeDate = calendar.dateByAddingUnit(.CalendarUnitDay, value: (numDay - (currentDayNumber-1)), toDate: currentDate, options: nil)
                pointsArray2[numDay].insertObject(relativeDate!, atIndex: 2)
                
                if(numDay == currentDayNumber-1) {
                    //pointsArray2[numDay].insertObject(currentDate, atIndex: 2) // challengeDate
                    pointsArray2[numDay].insertObject(dayChallengesArray, atIndex: 3) // challengesArray
                }
                else {
                    //pointsArray2[numDay].insertObject(NSDate(), atIndex: 2) // challengeDate
                    pointsArray2[numDay].insertObject(["",""], atIndex: 3) // challengesArray
                }
                pointsArray2[numDay].insertObject(-1, atIndex: 4) // selectedChallenge
                pointsArray2[numDay].insertObject("emptyPic", atIndex: 5) // challengeCompletePicture
                pointsArray2[numDay].insertObject("", atIndex: 6) // challengeCompleteText
                pointsArray2[numDay].insertObject(0, atIndex: 7) // challengeShared
            }
        }
    }
    
    func saveData() {
        // Save all data
        defaults.setObject(pointsArray2, forKey: "pointsArray")
        defaults.setObject("true", forKey: "hasSaved")
    }
    
    func createData() {
        //GetServerCurrentDayNumberAndDate tem retorno duplo, um NSInteger e um NSDate
        var (currentDayNumber : NSInteger,currentDate : NSDate) = ServerConnection.sharedInstance.GetServerCurrentDayNumberAndDate()
        
        //Load a day challenge GetChallenges(dayNumber, langId 0=en, 1=pt)
        var langId = 1
        var dayChallengesArray = ServerConnection.sharedInstance.GetChallenges(currentDayNumber, lang: langId) as! [String]
        
        pointsArray2 = NSMutableArray()
        for var numDay=0; numDay < currentDayNumber; numDay++ {
            pointsArray2.insertObject(NSMutableArray(), atIndex: numDay)
            pointsArray2[numDay].insertObject(PointState.Unfinished.rawValue, atIndex: 0) // challengeState
            pointsArray2[numDay].insertObject(numDay+1, atIndex: 1) // challengeGlobalDay
            
            
            let calendar : NSCalendar = NSCalendar.currentCalendar()
            let relativeDate = calendar.dateByAddingUnit(.CalendarUnitDay, value: (numDay - (currentDayNumber-1)), toDate: currentDate, options: nil)
            pointsArray2[numDay].insertObject(relativeDate!, atIndex: 2)
            
            if(numDay == currentDayNumber-1) {
                //pointsArray2[numDay].insertObject(currentDate, atIndex: 2) // challengeDate
                pointsArray2[numDay].insertObject(dayChallengesArray, atIndex: 3) // challengesArray
            }
            else {
                //pointsArray2[numDay].insertObject(NSDate(), atIndex: 2) // challengeDate
                pointsArray2[numDay].insertObject(["",""], atIndex: 3) // challengesArray
            }
            pointsArray2[numDay].insertObject(-1, atIndex: 4) // selectedChallenge
            pointsArray2[numDay].insertObject("emptyPic", atIndex: 5) // challengeCompletePicture
            pointsArray2[numDay].insertObject("", atIndex: 6) // challengeCompleteText
            pointsArray2[numDay].insertObject(0, atIndex: 7) // challengeShared
            
            
        }
        
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
        
        let dayNumber = timelinePoint.getDay()
        let langId = 0 //TODO: Definir o id do idioma aqui quando o suporte a multilinguas estiver implementado, 0=en 1=pt
        let pointDate : NSDate = timelinePoint.getDate()
        
        // Check if it has updated point Data from server
        var dayChallengesArray = timelinePoint.getChallenges()
        if(dayChallengesArray[0] == "") {
            //Load a day challenge GetChallenges(dayNumber, langId 0=en, 1=pt)
            dayChallengesArray = ServerConnection.sharedInstance.GetChallenges(dayNumber, lang: langId) as! [String]
            
            // Update timelinePoint data
            timelinePoint.setInitialData(dayNumber, cDate: pointDate, chlg: dayChallengesArray)
            
            // Update array data and save it
            pointsArray2[dayNumber].insertObject(dayChallengesArray, atIndex: 3)
            saveData()
        }
        

        selectedTimelinePoint = timelinePoint

        popOverController.timelineViewController = self
        popOverController.timelinePoint = timelinePoint
        
        
        popOverController.challenge1.setTitle(dayChallengesArray[0], forState: .Normal)
        
        if(dayChallengesArray.count > 1) {
            popOverController.challenge2.setTitle(dayChallengesArray[1], forState: .Normal)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "GoToGlobalStats"){
            let globalStatsController = segue.destinationViewController as! GlobalStatsController
            
            globalStatsController.selectedTimelinePoint = selectedTimelinePoint
            globalStatsController.changeChoice = isChangingChoice
        }
    }
    

}

