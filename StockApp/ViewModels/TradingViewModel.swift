//
//  TradingViewModel.swift
//  StockApp
//
//  Created by Boda Song on 4/20/24.
//

import SwiftUI
import Alamofire
import SwiftyJSON

class TradingViewModel: ObservableObject {
    @Published var inputQuantity: String = ""
    @Published var currentQuantity: Int = 0
    @Published var sharePrice: Double = 0.0
    @Published var balance: Double = 0.0
    @Published var stockId: String = ""
    @Published var totalCost: Double = 0.0
    @Published var symbol: String = ""
    @Published var name: String = ""
    @Published var balanceId: String = ""
//    private var host = "http://127.0.0.1:3000"
    private let host = "https://stockapp26-421000.wl.r.appspot.com"
    
    var totalPrice: Double {
        if let quantity = Int(inputQuantity) {
            return Double(quantity) * sharePrice
        }
        return 0.0
    }
    
    func onBuyButtonClicked() {
        if (currentQuantity > 0) {
            
            // current hold stock
            let urlString = "\(host)/api/portfolio/\(stockId)"
            
            let updatedQuantity = currentQuantity + Int(inputQuantity)!
            let updatedTotalCost = totalCost + sharePrice * Double(inputQuantity)!
            
            let data = [
                "quantity": updatedQuantity,
                "totalCost": updatedTotalCost
            ] as [String : Any]
            
            AF.request(urlString, method: .put, parameters: data, encoding: JSONEncoding.default).response { [self] response in
                switch response.result {
                case .success(let value):
                    print("successfully bought \(inputQuantity) shares of old stock \(symbol)")
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        } else {
            // donot hold stock
            let urlString = "\(host)/api/portfolio"
            
            let newQuantity = Int(inputQuantity)!
            let newTotalCost = sharePrice * Double(inputQuantity)!
            
            let data = [
                "symbol": symbol,
                "name": name,
                "quantity": newQuantity,
                "totalCost": newTotalCost,
                "latestPrice": sharePrice
            ] as [String : Any]

            AF.request(urlString, method: .post, parameters: data, encoding: JSONEncoding.default).response { [self] response in
                switch response.result {
                case .success(let value):
                    print("successfully bought \(inputQuantity) shares of new stock \(symbol)")
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
        
        let balanceUrlString = "\(host)/api/balance/\(balanceId)"
        balance -= totalPrice
        let balanceData = [
            "balance": balance
        ] as [String : Any]
        print(balanceData)
        
        AF.request(balanceUrlString, method: .put, parameters: balanceData, encoding: JSONEncoding.default).response { [self] response in
            switch response.result {
            case .success(let value):
                print("updated balance: \(balance)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func onSellButtonClicked() {
        if (Int(inputQuantity) == currentQuantity) {
            // sell all stocks
            let urlString = "\(host)/api/portfolio/\(stockId)"
            AF.request(urlString, method: .delete).response { response in
                switch response.result {
                case .success:
                    print("successfully sold all stocks: \(self.stockId)")
                case .failure(let error):
                    print("delete error")
                }
            }
            
        } else {
            let urlString = "\(host)/api/portfolio/\(stockId)"
            let updatedQuantity = currentQuantity - Int(inputQuantity)!
            let updatedTotalCost = totalCost - sharePrice * Double(inputQuantity)!
            let data = [
                "quantity": updatedQuantity,
                "totalCost": updatedTotalCost
            ] as [String : Any]
            AF.request(urlString, method: .put, parameters: data, encoding: JSONEncoding.default).response { [self] response in
                switch response.result {
                case .success(let value):
                    print("successfully sold \(inputQuantity) shares of stock \(symbol)")
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
        let balanceUrlString = "\(host)/api/balance/\(balanceId)"
        balance += totalPrice
        let balanceData = [
            "balance": balance
        ] as [String : Any]
        print(balanceData)
        
        AF.request(balanceUrlString, method: .put, parameters: balanceData, encoding: JSONEncoding.default).response { [self] response in
            switch response.result {
            case .success(let value):
                print("updated balance: \(balance)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
}
