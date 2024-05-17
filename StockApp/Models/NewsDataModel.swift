//
//  NewsDataModel.swift
//  StockApp
//
//  Created by Boda Song on 4/18/24.
//

import Foundation

struct NewsDataModel: Decodable, Identifiable {
    var category: String
    var datetime: Int64
    var headline: String
    var id: Int64
    var image: String
    var related: String
    var source: String
    var summary: String
    var url: String
}

extension NewsDataModel {
    var timeAgo: String {
        let articleDate = Date(timeIntervalSince1970: TimeInterval(datetime))
        let currentDate = Date()
        let components = Calendar.current.dateComponents([.hour, .minute], from: articleDate, to: currentDate)

        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        var timeAgo = ""
        
        if hour > 0 {
            timeAgo += "\(hour) hr"
        }
        
        if minute > 0 {
            if !timeAgo.isEmpty { timeAgo += ", " }
            timeAgo += "\(minute) min"
        }
        
        if timeAgo.isEmpty {
            timeAgo = "Just now"
        }
        
        return timeAgo
    }
}
