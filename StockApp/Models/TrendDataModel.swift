//
//  TrendDataModel.swift
//  StockApp
//
//  Created by Boda Song on 4/17/24.
//

struct TrendDataModel: Decodable {
    var buy: Int
    var hold: Int
    var period: String
    var sell: Int
    var strongBuy: Int
    var strongSell: Int
    var symbol: String
}
