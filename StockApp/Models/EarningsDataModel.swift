//
//  EarningsDataModel.swift
//  StockApp
//
//  Created by Boda Song on 4/17/24.
//

struct EarningsDataModel: Decodable {
    var actual: Double
    var estimate: Double
    var period: String
    var quarter: Int
    var surprise: Double
    var surprisePercent: Double
    var symbol: String
    var year: Int
}
