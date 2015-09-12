//
//  DiagnosticLogger.swift
//  Naterade
//
//  Created by Nathan Racklyeft on 9/10/15.
//  Copyright © 2015 Nathan Racklyeft. All rights reserved.
//

import Foundation
import MinimedKit


class DiagnosticLogger {
    let APIKey: String
    let APIHost: String
    let APIPath: String

    init?() {
        if let
            settingsPath = NSBundle.mainBundle().pathForResource("RemoteSettings", ofType: "plist"),
            settings = NSDictionary(contentsOfFile: settingsPath)
        {
            APIKey = settings["APIKey"] as! String
            APIHost = settings["APIHost"] as! String
            APIPath = settings["APIPath"] as! String
        } else {
            APIKey = ""
            APIHost = ""
            APIPath = ""

            return nil
        }
    }

    func addMessage(message: MySentryPumpStatusMessageBody) {
        if let messageData = try? NSJSONSerialization.dataWithJSONObject(message.dictionaryRepresentation, options: []),
            let URL = NSURL(string: APIHost)?.URLByAppendingPathComponent(APIPath).URLByAppendingPathComponent("sentryMessage"),
            components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true)
        {
            components.query = "apiKey=\(APIKey)"

            if let URL = components.URL {
                let request = NSMutableURLRequest(URL: URL)

                request.HTTPMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let task = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: messageData) { (_, _, error) -> Void in
                    if let error = error {
                        NSLog("%s error: %@", __FUNCTION__, error)
                    }
                }

                task.resume()
            }
        }


    }
}