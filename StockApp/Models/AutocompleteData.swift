//
//  AutocompleteData.swift
//  StockApp
//
//  Created by Boda Song on 4/3/24.
//

struct AutocompleteData: Decodable {
    var count: Int
    var result: [StockItem]
}
