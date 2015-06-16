//
//  ServerConnection.swift
//  DoIt
//
//  Created by Rodrigo Dias Takase on 10/06/15.
//  Copyright (c) 2015 CoffeeTime. All rights reserved.
//

import Foundation
import UIKit

class ServerConnection{
    static let sharedInstance = ServerConnection()
    let serverPath = "http://www.gamescamp.com.br/dailychallenge/webservices/"
    
    var userid = "0"
    
    func InsertUser(){
        var sendData : NSString = "deviceid=" + UIDevice.currentDevice().identifierForVendor.UUIDString
        
        RequestPHP(sendData,phpFileName: "insertUser.php", method: "POST", completionHandler:{ (strFromServer: String)->() in
            self.userid = strFromServer
        })
        
    }
    
    func GetChallenges(day : NSInteger, lang : NSInteger,completionHandler: NSArray -> ()){
        var sendData : NSString = "day=" + day.description + "&lang=" + lang.description
        RequestPHP(sendData,phpFileName: "getChallenges.php", method: "POST", completionHandler:{ (strFromServer: String)->() in
            
            completionHandler(split(strFromServer) {$0 == "#"})
        })
    }
    
    func ChallengeAccomplished(choice : NSInteger, day : NSInteger,completionHandler: NSArray -> ()){
        
        
        if(userid != "-1"){
            var sendData : NSString = "userid=" + userid + "&day=" + day.description + "&choice=" + choice.description
            
            RequestPHP(sendData,phpFileName: "insertAccomplished.php", method: "POST", completionHandler:{ (strFromServer: String)->() in
                
                completionHandler(split(strFromServer) {$0 == "#"})
            })
        }
    }
    
    func GetGlobalStats(day : NSInteger,completionHandler: NSArray -> ()){
        var sendData : NSString = "day=" + day.description
        RequestPHP(sendData,phpFileName: "getGlobalStat.php", method: "POST", completionHandler:{ (strFromServer: String)->() in
            
            completionHandler(split(strFromServer) {$0 == "#"})
        })
        
    }
    
    func GetServerCurrentDayNumberAndDate(completionHandler: (NSInteger,NSDate) -> ()){
        
        RequestPHP("",phpFileName: "getDay0_1.php", method: "POST", completionHandler:{ (strFromServer: String)->() in
            let days = split(strFromServer) {$0 == "#"}
            let utcDateFormatter = NSDateFormatter()
            utcDateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
            utcDateFormatter.locale = NSLocale(localeIdentifier: "en_US")
            utcDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            //Get Date 0 in GMT
            let serverStringDate0 = days[0]
            let date0 = utcDateFormatter.dateFromString(serverStringDate0)
            
            //Get Current Date in GMT
            let serverStringCurrentDate = days[1]
            let currentDate = utcDateFormatter.dateFromString(serverStringCurrentDate)
            
            //Calculates Current Day number
            var secondsBetween : NSTimeInterval = currentDate!.timeIntervalSinceDate(date0!)
            var currentDayNumber = Int(secondsBetween / 86400);
            
            let localDateFormatter = NSDateFormatter()
            localDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
            localDateFormatter.timeStyle = NSDateFormatterStyle.LongStyle
            let localDateString = localDateFormatter.stringFromDate(currentDate!)
            
            completionHandler(currentDayNumber,currentDate!)
        })
        
    }
    
    func RequestPHP(sendData : NSString, phpFileName : String, method: String, completionHandler: String -> ()){
        var request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: serverPath + phpFileName)!)
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        
        request.HTTPBody = sendData.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = method
        
        let queue:NSOperationQueue = NSOperationQueue()
        
        let urlData: Void = NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var results : NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
            if ((error) != nil){
                println(error)
            }else{
                completionHandler(results as String)
            }
        })
    }
}