//
//  ProfileModel.swift
//  StockApp
//
//  Created by Boda Song on 4/3/24.
//

import SwiftyJSON

struct Profile {
    var country: String
    var currency: String
    var estimateCurrency: String
    var exchange: String
    var finnhubIndustry: String
    var ipo: String
    var logo: String
    var marketCapitalization: Double
    var name: String
    var phone: String
    var shareOutstanding: Double
    var ticker: String
    var weburl: String
    
    init(json: JSON) {
        self.country = json["country"].stringValue
        self.currency = json["currency"].stringValue
        self.estimateCurrency = json["estimateCurrency"].stringValue
        self.exchange = json["exchange"].stringValue
        self.finnhubIndustry = json["finnhubIndustry"].stringValue
        self.ipo = json["ipo"].stringValue
        self.logo = json["logo"].stringValue
        self.marketCapitalization = json["marketCapitalization"].doubleValue
        self.name = json["name"].stringValue
        self.phone = json["phone"].stringValue
        self.shareOutstanding = json["shareOutstanding"].doubleValue
        self.ticker = json["ticker"].stringValue
        self.weburl = json["weburl"].stringValue
    }
    
}
