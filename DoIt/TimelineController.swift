//
//  ViewController.swift
//  DoIt
//
//  Created by Danilo S Marshall on 6/10/15.
//  Copyright (c) 2015 CoffeeTime. All rights reserved.
//

import UIKit


@objc protocol TimelineDelegate {
    func updateSelectedChallenge(pointDay : Int, chosenChallenge : Int)
    func updateChallengePicture(pointDay : Int, challengePic : UIImage)
    func updateChallengeText(pointDay : Int, challengeTxt : String)
}


class TimelineController: UIViewController,UIPopoverPresentationControllerDelegate, TimelineDelegate {
    @IBOutlet var defaultTimelinebutton: TimelinePoint!
    
    @IBOutlet var doneChallengesLabel: UILabel!
    
    @IBOutlet var timerLabel: UILabel!
    
    var timelineView : UIView!
    var timelineScroll : UIScrollView!
    var timelineAnchor : UIView!
    var pointsArray : NSMutableArray!
    
    var doneChallengesInt : Int=0
    
    var selectedTimelinePoint : TimelinePoint!
    var isChangingChoice = false
    
    var timerhour:Int = 0
    var timerminute:Int = 0
    var timersecond:Int = 0
    
    var timer = NSTimer()
    
    let lg = NSLocale.preferredLanguages()[0] as! String
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineView=UIView(frame: self.view.frame)
        
        timelineView.setTranslatesAutoresizingMaskIntoConstraints(true)
        
        self.view.addSubview(timelineView)
        
        loadTimeLineData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        
        self.navigationController!.navigationBar.tintColor=UIColor.whiteColor()
        self.navigationController!.navigationBar.barTintColor=UIColor(red: 98/255, green: 185/255, blue: 246/255, alpha: 1.0)
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as [NSObject : AnyObject]
        
        setupTimer()
    }
    
    func loadTimeLineData(){
        //TODO: Pull data from the server. Loading fake data for now
        
        //Supposed server array ordenation: 1stday-2ndday-3rdday and it goes
        loadData({
            dispatch_async(dispatch_get_main_queue()){
                //Making points=========
                self.doneChallengesInt=0
                let screenSize: CGRect = UIScreen.mainScreen().bounds
                //  var x:CGFloat=screenSize.width/2-20
                let y:CGFloat=screenSize.height-60
                
                let scrollInitialX:CGFloat = self.view.frame.width
                let pointsNumber = CGFloat(self.pointsArray.count)
                let scrollWidth = ((self.defaultTimelinebutton.frame.width)*(pointsNumber+3))
                self.timelineScroll = UIScrollView(frame: CGRectMake(0, y, self.view.frame.width, 120))
                var x:CGFloat=scrollWidth-self.defaultTimelinebutton.frame.width
                
                self.timelineScroll.contentSize = CGSizeMake(scrollWidth, 120);
                
                
                self.timelineView.addSubview(self.timelineScroll)
                
                
                self.timelineAnchor = UIView(frame: CGRectMake(screenSize.width/2, y-10, 1, 1))
                
                self.timelineView.addSubview(self.timelineAnchor)
                
                //Create Locked points
                var numLockedPoints = 5
                for var j=0; j<numLockedPoints; j++
                {
                    var newPoint:TimelinePoint = TimelinePoint(frame: CGRectMake(0, 0, 75, 50), cDay: j, cDate: NSDate(), chlg: ["",""], cState: PointState.Locked,selChlg: -1)
                    // newPoint = defaultTimelinebutton
                    newPoint.frame = CGRectMake(x+150, 11, 75, 50)
                    //newPoint.changeState(PointState.Locked)
                    newPoint.UpdateDateLabel(99, dayL: 99, indexL: (self.pointsArray[self.pointsArray.count-1][1] as! Int)+numLockedPoints-j)
                    self.timelineScroll.addSubview(newPoint)
                    
                    x-=75;
                    
                }
                
                //And the unlocked points
                
                x=scrollWidth-75 - (75*3) //5=locked points number
                
                //println(self.pointsArray.count)
                
                for var i=self.pointsArray.count-1; i>=0; i--
                {
                    
                    let date : NSDate = self.pointsArray[i][2] as! NSDate
                    let calendar: NSCalendar = NSCalendar.currentCalendar()
                    let components = calendar.components(.CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
                    
                    var newPoint:TimelinePoint = TimelinePoint(frame: CGRectMake(90, 50, 75, 50), cDay: self.pointsArray[i][1] as! Int, cDate: date, chlg: self.pointsArray[i][3] as! [String], cState: PointState(rawValue: (self.pointsArray[i][0] as! Int))!, selChlg: self.pointsArray[i][4] as! Int)
                    //PointState(rawValue: decoder.decodeObjectForKey("currentState") as! Int)!
                    //println("Point \(i): \(PointState(rawValue: (self.pointsArray[i][0] as! Int))!)")
                    //var newPoint:TimelinePoint = TimelinePoint(frame: CGRectMake(90, 40, 45, 45))
                    // newPoint = defaultTimelinebutton
                    newPoint.frame = CGRectMake(x, 11, 75, 50)
                    //newPoint.changeState(PointState.Finished)
                    self.timelineScroll.addSubview(newPoint)
                    newPoint.button.addTarget(self, action: "timelineButTouched:", forControlEvents: UIControlEvents.TouchUpInside)
                    
                    //let month:String = self.pointsArray[i-1][0] as! String
                    //let day:String = self.pointsArray[i-1][1] as! String
                    
                    newPoint.UpdateDateLabel(components.month, dayL: components.day, indexL:self.pointsArray[i][1] as! Int)
                    x-=75;
                    
                    //Update complete challenge's number
                    if (newPoint.getState() == PointState.Finished){
                        
                        self.doneChallengesInt++
                        
                    }
                    
                    //Center onto the current day's button
                    if (i == (self.pointsArray.count-1)){
                        self.CenterTimelineAt(newPoint.button)
                        if (newPoint.getState() == PointState.Finished){
                        }
                            //!= not working?
                        else{
                            self.timelineButTouched(newPoint.button)
                        }
                    }
                    
                }
                //=======================
                
                self.defaultTimelinebutton.hidden=true
                self.doneChallengesLabel.text = String(self.doneChallengesInt)
            }
        })
        //println(lg)
    }

    func CenterTimelineAt(sender: AnyObject) {
        
        let frame = sender.convertPoint(sender.frame.origin, toView: timelineScroll)
        println(frame.x)
        let newOffset = CGPointMake(frame.x-(self.view.frame.size.width / 2)+35, 0);
        timelineScroll.setContentOffset(newOffset, animated: true)
    }
    
    @IBAction func timelineButTouched(sender: AnyObject) {
        //Show PopOver
        let popOverController=self.storyboard!.instantiateViewControllerWithIdentifier("PopOverDefault") as! PopOverController
        popOverController.view.backgroundColor=UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        popOverController.modalPresentationStyle = .Popover
        popOverController.delegateTimeline = self
        popOverController.preferredContentSize = CGSizeMake(self.view.frame.size.width-16, 400)
        
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
    
    
    override func viewWillDisappear(animated: Bool) {
        
        self.navigationController!.navigationBar.tintColor=UIColor(red: 98/255, green: 185/255, blue: 246/255, alpha: 1.0)
        self.navigationController!.navigationBar.barTintColor=UIColor.whiteColor()
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor(red: 98/255, green: 185/255, blue: 246/255, alpha: 1.0)]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as [NSObject : AnyObject]

    }
    
    override func viewDidDisappear(animated: Bool) {
        
        timer.invalidate()
    }
    
    func setupTimer(){
        //Getting the NSDate for the end of the current day
        
        ServerConnection.sharedInstance.GetServerCurrentDayNumberAndDate({ (currentDayNumber : NSInteger,currentDate: NSDate)->() in
            println(currentDate)
            let cal = NSCalendar.currentCalendar()
            let components = cal.components((.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond), fromDate: currentDate)
            
            let hour = components.hour
            let minute = components.minute
            let second = components.second
            
            self.timerhour=23-hour
            self.timerminute=59-minute
            self.timersecond=59-second
            
            dispatch_async(dispatch_get_main_queue()){
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("timerUpdate"), userInfo: nil, repeats: true)
            }
            
        })
        
    }
        
    func timerUpdate() {

        timersecond--
        if (timersecond<=0){
            timersecond=59
            timerminute--
            if (timerminute<=0){
                timerminute=59
                timerhour--
                if (timerhour<=0){
                    timerhour=23
                    timerminute=59
                    timersecond=59
                }
            }
        }
        
        timerLabel.text=NSString(format: "%02d:%02d:%02d", timerhour,timerminute,timersecond) as String
        
    }
    
    
    func loadData(completionHandler: (() -> Void)) {
        //check if there is any saved Data
        if var hasSaved = defaults.stringForKey("hasSaved") as String! {
            // has saved, get data
            if(hasSaved == "false") {
                println("hasSaved is false - Create new Data")
                createData({
                    
                    self.saveData()
                    completionHandler()
                })
            }
            else {
                println("hasSaved is true - Fetch Data")
                self.pointsArray = self.defaults.objectForKey("pointsArray") as! NSMutableArray
                
                // TODO: check current day of server and add missing days from saved Data
                // TODO: recover image string to image, if value is different then default "emptyPic"
                addData({
                    self.saveData()
                    completionHandler()
                })
            }
        }
        else {
            // haven't saved yet, need to create objects
            println("hasSaved don't exist - Create new Data")
            
            createData({
                self.saveData()
                completionHandler()
            })
        }
        
    }
    
    func addData(completionHandler: (() -> Void)!) {
        //GetServerCurrentDayNumberAndDate tem retorno duplo, um NSInteger e um NSDate
        ServerConnection.sharedInstance.GetServerCurrentDayNumberAndDate({ (currentDayNumber : NSInteger,currentDate: NSDate)->() in
            
            
            let lastSavedDay = self.pointsArray[self.pointsArray.count-1][1] as! Int
            
            if(currentDayNumber == lastSavedDay) {
                // Number of timelinePoints is up to date
                println("timelinePoint array is up to date")
                completionHandler()
            }
            else {
                println("timelinePoint array is missing \(currentDayNumber - lastSavedDay) days")
                
                if(currentDayNumber - lastSavedDay < 0) {
                    println("Error: Need to erase app before testing - more days in saved data then in server")
                }
                
                
                //Load a day challenge GetChallenges(dayNumber, langId 0=en, 1=pt)
                var langId = -1
                if(self.lg == "pt") {
                    langId = 1
                }
                else {
                    langId = 0
                }
                
                ServerConnection.sharedInstance.GetChallenges(currentDayNumber,lang: langId, completionHandler:{ (arrayFromServer: NSArray)->() in
                    let dayChallengesArray = arrayFromServer as! [String]
                    
                    for var numDay = lastSavedDay; numDay < currentDayNumber; numDay++ {
                        self.pointsArray.insertObject(NSMutableArray(), atIndex: numDay)
                        self.pointsArray[numDay].insertObject(PointState.Unfinished.rawValue, atIndex: 0) // challengeState
                        self.pointsArray[numDay].insertObject(numDay+1, atIndex: 1) // challengeGlobalDay
                        
                        
                        let calendar : NSCalendar = NSCalendar.currentCalendar()
                        let relativeDate = calendar.dateByAddingUnit(.CalendarUnitDay, value: (numDay - (currentDayNumber-1)), toDate: currentDate, options: nil)
                        self.pointsArray[numDay].insertObject(relativeDate!, atIndex: 2)
                        
                        if(numDay == currentDayNumber-1) {
                            //pointsArray[numDay].insertObject(currentDate, atIndex: 2) // challengeDate
                            self.pointsArray[numDay].insertObject(dayChallengesArray, atIndex: 3) // challengesArray
                        }
                        else {
                            //pointsArray[numDay].insertObject(NSDate(), atIndex: 2) // challengeDate
                            self.pointsArray[numDay].insertObject(["",""], atIndex: 3) // challengesArray
                        }
                        self.pointsArray[numDay].insertObject(-1, atIndex: 4) // selectedChallenge
                        self.pointsArray[numDay].insertObject("emptyPic", atIndex: 5) // challengeCompletePicture
                        self.pointsArray[numDay].insertObject("", atIndex: 6) // challengeCompleteText
                        self.pointsArray[numDay].insertObject(0, atIndex: 7) // challengeShared
                    }
                    completionHandler()
                })
            }
        })
    }
    
    func saveData() {
        // Save all data
        defaults.setObject(pointsArray, forKey: "pointsArray")
        defaults.setObject("true", forKey: "hasSaved")
        
        
        println("Array: \(self.pointsArray)")
    }
    
    func createData(completionHandler: (() -> Void)!) {
        //GetServerCurrentDayNumberAndDate tem retorno duplo, um NSInteger e um NSDate
        ServerConnection.sharedInstance.GetServerCurrentDayNumberAndDate({ (currentDayNumber : NSInteger,currentDate: NSDate)->() in
            
            
            //Load a day challenge GetChallenges(dayNumber, langId 0=en, 1=pt)
            var langId = -1
            if(self.lg == "pt") {
                langId = 1
            }
            else {
                langId = 0
            }
            ServerConnection.sharedInstance.GetChallenges(currentDayNumber,lang: langId, completionHandler:{ (arrayFromServer: NSArray)->() in
                let dayChallengesArray = arrayFromServer as! [String]
                
                self.pointsArray = NSMutableArray()
                for var numDay=0; numDay < currentDayNumber; numDay++ {
                    self.pointsArray.insertObject(NSMutableArray(), atIndex: numDay)
                    self.pointsArray[numDay].insertObject(PointState.Unfinished.rawValue, atIndex: 0) // challengeState
                    self.pointsArray[numDay].insertObject(numDay+1, atIndex: 1) // challengeGlobalDay
                    
                    
                    let calendar : NSCalendar = NSCalendar.currentCalendar()
                    let relativeDate = calendar.dateByAddingUnit(.CalendarUnitDay, value: (numDay - (currentDayNumber-1)), toDate: currentDate, options: nil)
                    self.pointsArray[numDay].insertObject(relativeDate!, atIndex: 2)
                    
                    if(numDay == currentDayNumber-1) {
                        //pointsArray[numDay].insertObject(currentDate, atIndex: 2) // challengeDate
                        self.pointsArray[numDay].insertObject(dayChallengesArray, atIndex: 3) // challengesArray
                    }
                    else {
                        //pointsArray[numDay].insertObject(NSDate(), atIndex: 2) // challengeDate
                        self.pointsArray[numDay].insertObject(["",""], atIndex: 3) // challengesArray
                    }
                    self.pointsArray[numDay].insertObject(-1, atIndex: 4) // selectedChallenge
                    self.pointsArray[numDay].insertObject("emptyPic", atIndex: 5) // challengeCompletePicture
                    self.pointsArray[numDay].insertObject("", atIndex: 6) // challengeCompleteText
                    self.pointsArray[numDay].insertObject(0, atIndex: 7) // challengeShared
                    
                    
                }
                completionHandler()
            })
        })
    }
    
    /*
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
        ServerConnection.sharedInstance.GetServerCurrentDayNumberAndDate({ (currentDayNumber : NSInteger,currentDate: NSDate)->() in
            println("currentDayNumber = \(currentDayNumber)")
            println("currentDate = \(currentDate)")
        })
    }
    */

    func LoadPointData(popOverController : PopOverController, timelinePoint : TimelinePoint){
        
        let dayNumber = timelinePoint.getDay()
        var langId = -1
        if(self.lg == "pt") {
            langId = 1
        }
        else {
            langId = 0
        }
        let pointDate : NSDate = timelinePoint.getDate()
        
        // Check if it has updated point Data from server
        popOverController.ShowLoadingIndicator(true)
        var dayChallengesArray = timelinePoint.getChallenges()
        println("dayChallenges: \(dayChallengesArray)")
        if(dayChallengesArray[0] == "") {
            //Load a day challenge GetChallenges(dayNumber, langId 0=en, 1=pt)
            ServerConnection.sharedInstance.GetChallenges(dayNumber,lang: langId, completionHandler:{ (arrayFromServer: NSArray)->() in
                let dayChallengesArray = arrayFromServer as! [String]
                
                // Update timelinePoint data
                timelinePoint.setChallenges(dayChallengesArray)
                //timelinePoint.setInitialData(dayNumber, cDate: pointDate, chlg: dayChallengesArray)
                
                // Update array data and save it
                self.pointsArray[dayNumber-1].replaceObjectAtIndex(3, withObject: dayChallengesArray)
                //self.pointsArray[dayNumber-1].insertObject(dayChallengesArray, atIndex: 3)
                self.saveData()
                
                self.showChallengePointData(popOverController, timelinePoint: timelinePoint, dayChallengesArray : dayChallengesArray)
            })
        }
        else {
            // Challenge is already loaded
            
            // is challenge done?
            switch timelinePoint.getState() {
            case PointState.Unfinished:
                println("Unfinished")
                showChallengePointData(popOverController, timelinePoint: timelinePoint, dayChallengesArray : dayChallengesArray)
            case PointState.Finished:
                showCompleteChallengeData(popOverController, timelinePoint: timelinePoint)
                println("Finished")
            case PointState.Locked:
                //Do nothing
                println("Locked")
                break
            default:
                println("Default")
                showChallengePointData(popOverController, timelinePoint: timelinePoint, dayChallengesArray : dayChallengesArray)
            }
        }
        
    }
    
    func showChallengePointData (popOverController : PopOverController, timelinePoint : TimelinePoint, dayChallengesArray : [String]) {
        selectedTimelinePoint = timelinePoint
        
        popOverController.timelineViewController = self
        popOverController.timelinePoint = timelinePoint
        
        
        dispatch_async(dispatch_get_main_queue()){
            popOverController.challenge1.setTitle(dayChallengesArray[0], forState: .Normal)
            if(dayChallengesArray.count > 1) {
                popOverController.challenge2.setTitle(dayChallengesArray[1], forState: .Normal)
            }
            popOverController.ShowLoadingIndicator(false)
            popOverController.ShowChallenges()
        }
    }
    
    func showCompleteChallengeData (popOverController : PopOverController, timelinePoint : TimelinePoint) {
        selectedTimelinePoint = timelinePoint
        
        popOverController.timelineViewController = self
        popOverController.timelinePoint = timelinePoint
        
        //dispatch_async(dispatch_get_main_queue()){
        popOverController.ShowLoadingIndicator(false)
        popOverController.ShowChallengeComplete()
        //}
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "GoToGlobalStats"){
            let globalStatsController = segue.destinationViewController as! GlobalStatsController
            
            globalStatsController.selectedTimelinePoint = selectedTimelinePoint
            globalStatsController.changeChoice = isChangingChoice
        }
        if(segue.identifier == "GoToCompleteData") {
            let nextVC = (segue.destinationViewController as! ChallengeCompleteController)
            nextVC.timelinePoint=selectedTimelinePoint
            nextVC.timelineController = self
            nextVC.delegateTimeline=self
            nextVC.challengeTag=sender!.tag
        }
    }
    
    
    // MARK: - Delegate functions
    func updateSelectedChallenge(pointDay : Int, chosenChallenge : Int) {
        // TODO: update data with selected choice. May send to server also
        
        pointsArray[pointDay-1].replaceObjectAtIndex(4, withObject: chosenChallenge)
        pointsArray[pointDay-1].replaceObjectAtIndex(0, withObject: PointState.Finished.rawValue)
        
        doneChallengesInt++
        self.doneChallengesLabel.text = String(self.doneChallengesInt)
        
        saveData()
    }
    
    
    func updateChallengePicture(pointDay : Int, challengePic : UIImage) {
        let imageData = UIImagePNGRepresentation(challengePic)
        
        /*
        Save:
        UIImage *contactImage = contactImageView.image;
        NSData *imageData = UIImageJPEGRepresentation(contactImage, 100);
        
        Get:
        NSData *imageData = [defaults dataForKey:@"image"];
        UIImage *contactImage = [UIImage imageWithData:imageData];

        */
        
        //let base64ImgString = imageData.base64EncodedStringWithOptions(.allZeros)
        //encode.encodeObject(base64ImgString, forKey: "base64ImgString")
        
        // TODO: improve storing system for image, using local file system and saving path string on user defaults
        
        pointsArray[pointDay-1].replaceObjectAtIndex(5, withObject: imageData)
        saveData()
    }
    
    func updateChallengeText(pointDay : Int, challengeTxt : String) {
        pointsArray[pointDay-1].replaceObjectAtIndex(6, withObject: challengeTxt)
        saveData()
    }
}

