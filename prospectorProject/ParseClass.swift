//
//  ParseClass.swift
//  prospectorProject
//
//  Created by period3 on 12/6/18.
//  Copyright © 2018 period3. All rights reserved.
//

import Foundation
import UIKit

// We may be calling Parse twice in View Controller - Kai

class Parse
{
    var sources = [[String:String]]()
    
    
    let homePageQuery = "https://api.rss2json.com/v1/api.json?rss_url=https%3A%2F%2Fprospectornow.com%2F%3Ffeed%3Drss2"
    
    func parse(json: JSON)
    {
        print("Hello \(#line)")
        if let url = URL(string: homePageQuery)
        {
            if let data = try? Data(contentsOf: url)
            {
                let json = try! JSON(data: data)
                if json["status"] == "ok"
                {
                    print("Hello \(#line)")
                    parse(json: json)
                    return
                }
            }
        }
        for result in json["items"].arrayValue
        {
            print("Hello \(#line)")
           
            let title = result["title"].stringValue
            let pubDate = result["pubDate"].stringValue
            let description = result["description"].stringValue
            let content = result["content"].stringValue
            let articleThumbnail = result["thumbnail"].stringValue
            let source = ["title":title, "pubDate":pubDate, "description": description, "content":content]
            sources.append(source)
        }
        
        
        
        
        
        
    }
    
 
    
    
    
}
