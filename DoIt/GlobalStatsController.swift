//
//  GlobalStatsController.swift
//  DoIt
//
//  Created by Rodrigo Dias Takase on 12/06/15.
//  Copyright (c) 2015 CoffeeTime. All rights reserved.
//

import UIKit
import QuartzCore

class GlobalStatsController: UIViewController {
    
    @IBOutlet weak var chartContainerView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var lbDayNumber: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    
    @IBOutlet weak var lbPercentageChallenge1: UILabel!
    @IBOutlet weak var lbPercentageChallenge2: UILabel!
    
    @IBOutlet weak var lbChallenge1: UILabel!
    @IBOutlet weak var lbChallenge2: UILabel!
    
    @IBOutlet weak var lbMyChoice: UILabel!
    
    var selectedTimelinePoint : TimelinePoint!
    
    var changeChoice = false
    
    func UpdateGlobalStats(arrayFromServer : NSArray){
        let selectedChallenge = selectedTimelinePoint.getSelectedChallenge()
        
        let nAccomplished1 = (arrayFromServer[0] as! NSString).integerValue
        let nAccomplished2 = (arrayFromServer[1] as! NSString).integerValue
        
        let total = Double(nAccomplished1+nAccomplished2)
        
        var percentage1:Double = 50
        var percentage2:Double = 50
        
        if (total != 0){
         percentage1 = Double(nAccomplished1) / total * 100
         percentage2 = Double(nAccomplished2) / total * 100
        }
        
        self.ShowLoadingIndicator(false)
        
//        self.lbPercentageChallenge1.text = String(format:"%.1f", percentage1) + " %"
//        self.lbPercentageChallenge2.text = String(format:"%.1f", percentage2) + " %"
//        
//        self.lbChallenge1.text = self.selectedTimelinePoint.getChallenges()[0]
//        self.lbChallenge2.text = self.selectedTimelinePoint.getChallenges()[1]
        
        if(selectedChallenge == -1){
            //This is done on the storyboard now.
            //self.lbMyChoice.text = "You didn't accomplished any challenges yet on this day"
        }else{
            self.lbMyChoice.text = self.selectedTimelinePoint.getChallenges()[selectedChallenge]
        }
        

        var pieController:PieChartWindow = self.childViewControllers[0] as! PieChartWindow
        pieController.firstSlice = percentage1 as NSNumber
        pieController.secondSlice = percentage2 as NSNumber

        pieController.challenge1Label.text = selectedTimelinePoint.getChallenges()[0]
        pieController.challenge2Label.text = selectedTimelinePoint.getChallenges()[1]

        if(selectedChallenge == -1){
            //lbMyChoice.text = "You didn't accomplished any challenges yet on this day"
        }else{
            lbMyChoice.text = selectedTimelinePoint.getChallenges()[selectedChallenge]
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
        
        //lbDayNumber.text = "Day " + String(selectedTimelinePoint.getDay())
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        lbDate.text = formatter.stringFromDate(selectedTimelinePoint.getDate())
        
        let selectedChallenge = selectedTimelinePoint.getSelectedChallenge()

        
        var globalStats = []
        if(changeChoice){
//            
//            ServerConnection.sharedInstance.ChallengeAccomplished(selectedChallenge, day: selectedTimelinePoint.getDay(), completionHandler:{ (arrayFromServer: NSArray)->() in
//                
//                globalStats = arrayFromServer
//                
//                dispatch_async(dispatch_get_main_queue()){
//                    self.UpdateGlobalStats(arrayFromServer)
//                }
//            })
//            
            
            
            var arrayFromServer = ServerConnection.sharedInstance.ChallengeAccomplishedSynchronous(selectedChallenge, day: selectedTimelinePoint.getDay())
            self.UpdateGlobalStats(arrayFromServer)

        }else{

//            ServerConnection.sharedInstance.GetGlobalStats(selectedTimelinePoint.getDay(), completionHandler:{ (arrayFromServer: NSArray)->() in
//                
//                dispatch_async(dispatch_get_main_queue()){
//                   self.UpdateGlobalStats(arrayFromServer)
//                }
//            })
            
            var arrayFromServer = ServerConnection.sharedInstance.GetGlobalStatsSynchronous(selectedTimelinePoint.getDay())
            self.UpdateGlobalStats(arrayFromServer)

        }
        
//        let nAccomplished1 = (globalStats[0] as! NSString).integerValue
//        let nAccomplished2 = (globalStats[1] as! NSString).integerValue
//        
//        let total = Double(nAccomplished1+nAccomplished2)
//        let percentage1 = Double(nAccomplished1) / total * 100
//        let percentage2 = Double(nAccomplished2) / total * 100
//        
//        var pieController:PieChartWindow = self.childViewControllers[0] as! PieChartWindow
//        pieController.firstSlice = percentage1 as NSNumber
//        pieController.secondSlice = percentage2 as NSNumber
//        
//        pieController.challenge1Label.text = selectedTimelinePoint.getChallenges()[0]
//        pieController.challenge2Label.text = selectedTimelinePoint.getChallenges()[1]
//        
//        if(selectedChallenge == -1){
//            //lbMyChoice.text = "You didn't accomplished any challenges yet on this day"
//        }else{
//            lbMyChoice.text = selectedTimelinePoint.getChallenges()[selectedChallenge]
//        }
    }
    
    func ShowLoadingIndicator(bool : Bool){
//        lbDayNumber.hidden = bool
        lbDate.hidden = bool
//        lbPercentageChallenge1.hidden = bool
//        lbPercentageChallenge2.hidden = bool
//        lbChallenge1.hidden = bool
//        lbChallenge2.hidden = bool
        lbMyChoice.hidden = bool
        chartContainerView.hidden = bool
        
        activityIndicator.hidden = !bool
        
        if(bool){
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
        }
    }
}
