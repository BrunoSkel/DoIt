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
    
    func ChallengeAccomplished(choice : NSInteger, day : NSInteger){
        if(userid != "-1"){
            var sendData : NSString = "userid=" + userid + "&day=" + day.description + "&choice=" + choice.description
            
            var str = RequestPHP(sendData,phpFileName: "insertAccomplished.php", method: "POST")
            println(str)
        }
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