//
//  StockAppApp.swift
//  StockApp
//
//  Created by Boda Song on 3/31/24.
//

import SwiftUI

@main
struct StockAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SearchModel())
                .environmentObject(ContentViewModel())
        }
    }
}
