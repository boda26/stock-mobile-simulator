//
//  QuoteModel.swift
//  StockApp
//
//  Created by Boda Song on 4/9/24.
//

import SwiftyJSON

struct Quote {
    var c: Double
    var d: Double
    var dp: Double
    var h: Double
    var l: Double
    var o: Double
    var pc: Double
    var t: Double
    
    init(json: JSON) {
        self.c = json["c"].doubleValue
        self.d = json["d"].doubleValue
        self.dp = json["dp"].doubleValue
        self.h = json["h"].doubleValue
        self.l = json["l"].doubleValue
        self.o = json["o"].doubleValue
        self.pc = json["pc"].doubleValue
        self.t = json["t"].doubleValue
    }
}
