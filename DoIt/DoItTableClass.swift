//
//  DoItTableClass.swift
//  DoIt
//
//  Created by Bruno Henrique da Rocha e Silva on 6/19/15.
//  Copyright (c) 2015 CoffeeTime. All rights reserved.
//

import Foundation

class DoItTableClass: UITableViewController {
    @IBOutlet var textCheckMark: UILabel!
    @IBOutlet var pictureCheckMark: UILabel!
    @IBOutlet var noDataTableCell: UITableViewCell!
    @IBOutlet var DataTableCell: UITableViewCell!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
    }
    
    @IBAction func noDataCellTouched(sender: AnyObject) {
        self.goToGlobalStats()
    }
    
    func goToGlobalStats(){
        self.parentViewController?.navigationController?.popViewControllerAnimated(false)
        var parent:ChallengeCompleteController=self.parentViewController as! ChallengeCompleteController
        parent.timelineController.performSegueWithIdentifier("GoToGlobalStats", sender: parent.timelineController)
    }
    
}