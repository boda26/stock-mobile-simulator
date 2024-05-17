//
//  HistoryDataModel.swift
//  StockApp
//
//  Created by Boda Song on 4/15/24.
//

struct HistoryDataModel: Decodable {
    var v: Int
    var vw: Double
    var o: Double
    var c: Double
    var h: Double
    var l: Double
    var t: Int64
    var n: Int
}
