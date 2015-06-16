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

    @IBOutlet weak var lbDayNumber: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    
    @IBOutlet weak var lbPercentageChallenge1: UILabel!
    @IBOutlet weak var lbPercentageChallenge2: UILabel!
    
    @IBOutlet weak var lbChallenge1: UILabel!
    @IBOutlet weak var lbChallenge2: UILabel!
    
    @IBOutlet weak var lbMyChoice: UILabel!
    
    var selectedTimelinePoint : TimelinePoint!
    
    var changeChoice = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //lbDayNumber.text = "Day " + String(selectedTimelinePoint.getDay())
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        lbDate.text = formatter.stringFromDate(selectedTimelinePoint.getDate())
        
        let selectedChallenge = selectedTimelinePoint.getSelectedChallenge()
        
        var globalStats = []
        if(changeChoice){
            globalStats = ServerConnection.sharedInstance.ChallengeAccomplished(selectedChallenge, day: selectedTimelinePoint.getDay())
        }else{
            globalStats = ServerConnection.sharedInstance.GetGlobalStats(selectedTimelinePoint.getDay())
        }
        
        let nAccomplished1 = (globalStats[0] as! NSString).integerValue
        let nAccomplished2 = (globalStats[1] as! NSString).integerValue
        
        let total = Double(nAccomplished1+nAccomplished2)
        let percentage1 = Double(nAccomplished1) / total * 100
        let percentage2 = Double(nAccomplished2) / total * 100
        
        //lbPercentageChallenge1.text = String(format:"%.1f", percentage1) + " %"
        //lbPercentageChallenge2.text = String(format:"%.1f", percentage2) + " %"
        
        var pieController:PieChartWindow = self.childViewControllers[0] as! PieChartWindow
        pieController.firstSlice = percentage1 as NSNumber
        pieController.secondSlice = percentage2 as NSNumber
        
        pieController.challenge1Label.text = selectedTimelinePoint.getChallenges()[0]
        pieController.challenge2Label.text = selectedTimelinePoint.getChallenges()[1]
        
        if(selectedChallenge == -1){
            lbMyChoice.text = "You didn't accomplished any challenges yet on this day"
        }else{
            lbMyChoice.text = selectedTimelinePoint.getChallenges()[selectedChallenge]
        }
    }
}
