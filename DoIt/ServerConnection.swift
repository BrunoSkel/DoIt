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
        
        userid = RequestPHP(sendData,phpFileName: "insertUser.php", method: "POST")
        
    }
    
    func GetChallenges(day : NSInteger, lang : NSInteger) -> NSArray{
        var sendData : NSString = "day=" + day.description + "&lang=" + lang.description
        
        return split(RequestPHP(sendData,phpFileName: "getChallenges.php", method: "POST")) {$0 == "#"}
    }
    
    func ChallengeAccomplished(choice : NSInteger, day : NSInteger)  -> NSArray{
        if(userid != "-1"){
            var sendData : NSString = "userid=" + userid + "&day=" + day.description + "&choice=" + choice.description
            
            return split(RequestPHP(sendData,phpFileName: "insertAccomplished.php", method: "POST")) {$0 == "#"}
        }
        
        return []
    }
    
    func GetGlobalStats(day : NSInteger) -> NSArray{
        var sendData : NSString = "day=" + day.description
        
        return split(RequestPHP(sendData,phpFileName: "getGlobalStat.php", method: "POST")) {$0 == "#"}
    }
    
    func GetServerCurrentDayNumberAndDate() -> (NSInteger,NSDate){
        let days = split(RequestPHP("",phpFileName: "getDay0_1.php", method: "POST")) {$0 == "#"}

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
        
        // TEST for future date
        /*
        let calendar : NSCalendar = NSCalendar.currentCalendar()
        let futureDate = calendar.dateByAddingUnit(.CalendarUnitDay, value: 2, toDate: currentDate!, options: nil)
        let futureDay = currentDayNumber + 2
        return (futureDay,futureDate!)
        */
        
        return (currentDayNumber,currentDate!)
    }
    
    func RequestPHP(sendData : NSString, phpFileName : String, method: String) ->String{
        var request : NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: serverPath + phpFileName)!)
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        
        request.HTTPBody = sendData.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = method
        
        var response : NSURLResponse?
        var error : NSError?
        
        let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
        
        var results : NSString = NSString(data: urlData!, encoding: NSUTF8StringEncoding)!
        
        if let httpResponse = response as? NSHTTPURLResponse {
            //            println(httpResponse.statusCode)
        }
        
        if ((error) != nil){
            println(error)
            return "-1"
        }else{
            return results as String
        }
    }
}