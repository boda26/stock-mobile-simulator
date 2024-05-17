//
//  ContentViewModel.swift
//  StockApp
//
//  Created by Boda Song on 4/18/24.
//

import SwiftUI
import Alamofire
import SwiftyJSON

class ContentViewModel: ObservableObject {
//    private let host = "http://127.0.0.1:3000"
    
    private let host = "https://stockapp26-421000.wl.r.appspot.com"
    @Published var errorMessage: String?
    @Published var balance: Double = 0.0
    @Published var portfolioList: [JSON] = []
    @Published var quoteData: Quote?
    @Published var netWorth: Double = 0.0
    @Published var watchlist: [JSON] = []
    @Published var isLoading = false
    private var portfolioDict: [String: Double] = [:]
    private var watchlistDict: [String: [Double]] = [:]
    
    func fetchHomeData() {
        isLoading = true
        fetchBalance {
            self.fetchPortfolio {
                self.fetchLatestPrice {
                    self.updatePortfolioPrice {
                        self.fetchPortfolioAgain {
                            self.fetchWatchlist {
                                self.fetchWatchlistQuote {
                                    self.updateWatchlistPrice {
                                        self.fetchWatchlistAgain {
                                            self.isLoading = false
                                            print("finished loading")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchBalance(completion: @escaping () -> Void) {
        let urlString = "\(host)/api/balance"
        
        AF.request(urlString).validate().responseJSON { [weak self] response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self?.balance = json[0]["balance"].doubleValue
                    self?.netWorth = self!.balance
                    print("Loading Balance")
                    completion()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    
    func fetchPortfolio(completion: @escaping () -> Void) {

        let urlString = "\(host)/api/portfolio"
        
        AF.request(urlString).validate().responseJSON { [weak self] response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let resultsArray = json.array ?? []
                    
                    do {
                        let json = JSON(resultsArray)
                        self?.portfolioList = json.arrayValue
                        completion()
                        
                    } catch {
                        print("Decoding error: \(error)")
                        self?.errorMessage = "Error: Could not parse JSON"
                    }

                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchLatestPrice(completion: @escaping () -> Void) {

        let dispatchGroup = DispatchGroup()
        for item in portfolioList {
            guard let symbol = item["symbol"].string else { continue }
            dispatchGroup.enter()
            let urlString = "\(host)/api/quote/\(symbol)"
            AF.request(urlString).validate().responseJSON { [weak self] response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let value):
                        let quoteJSON = JSON(value)
                        if let latestPrice = quoteJSON["c"].double {
                            self?.netWorth += latestPrice * (item["quantity"].doubleValue)
                            self?.portfolioDict[symbol] = latestPrice
                        }
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }

    
    func updatePortfolioPrice(completion: @escaping () -> Void) {
//        guard !portfolioList.isEmpty else { return }

        let dispatchGroup = DispatchGroup()
        for item in portfolioList {
            guard let symbol = item["symbol"].string, let latestPrice = portfolioDict[symbol] else { continue }
            dispatchGroup.enter()
            let parameters = ["latestPrice": latestPrice]
            let updateUrlString = "\(host)/api/portfolio/\(item["_id"])"

            AF.request(updateUrlString, method: .put, parameters: parameters, encoding: JSONEncoding.default).response { response in
                switch response.result {
                case .success(_):
                    print("updated \(symbol) successfully")
                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }

    
    func fetchPortfolioAgain(completion: @escaping () -> Void) {
        let urlString = "\(self.host)/api/portfolio"

        AF.request(urlString).validate().responseJSON { [weak self] response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let resultsArray = json.array ?? []

                    do {
                        let json = JSON(resultsArray)
                        self?.portfolioList = json.arrayValue
                        print("fetched portfolio again!")
                        completion()

                    } catch {
                        print("Decoding error: \(error)")
                        self?.errorMessage = "Error: Could not parse JSON"
                    }

                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchWatchlist(completion: @escaping () -> Void) {
        let urlString = "\(host)/api/watchlist"
        AF.request(urlString).validate().responseJSON { [weak self] response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let resultsArray = json.array ?? []
                    do {
                        let json = JSON(resultsArray)
                        self?.watchlist = json.arrayValue
                        completion()

                    } catch {
                        print("Decoding error: \(error)")
                        self?.errorMessage = "Error: Could not parse JSON"
                    }
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchWatchlistQuote(completion: @escaping () -> Void) {
//        guard !watchlist.isEmpty else {
//            return
//        }
        let dispatchGroup = DispatchGroup()
        
        for (index, item) in watchlist.enumerated() {
            guard let symbol = item["symbol"].string else {
                continue
            }
            dispatchGroup.enter()
            let urlString = "\(self.host)/api/quote/\(symbol)"
            AF.request(urlString).validate().responseJSON { [weak self] response in
                DispatchQueue.main.async { [self] in
                    switch response.result {
                    case .success(let value):
                        let quoteJSON = JSON(value)
                        if let latestPrice = quoteJSON["c"].double,
                           let change = quoteJSON["d"].double,
                           let changePercent = quoteJSON["dp"].double
                        {
                            self?.watchlistDict[symbol] = [latestPrice, change, changePercent]
                        }
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    func updateWatchlistPrice(completion: @escaping () -> Void) {
//        guard !watchlist.isEmpty else {
//            return
//        }
        let dispatchGroup = DispatchGroup()
        
        for (index, item) in watchlist.enumerated() {
            guard let symbol = item["symbol"].string else {
                continue
            }
            dispatchGroup.enter()
            let updateUrlString = "\(self.host)/api/watchlist/\(item["_id"])"
            print(updateUrlString)
            
            let parameters = [
                "latestPrice": watchlistDict[symbol]![0],
                "change": watchlistDict[symbol]![1],
                "changePercent": watchlistDict[symbol]![2]
            ]
            
            AF.request(updateUrlString, method: .put, parameters: parameters, encoding: JSONEncoding.default).response { response in
                switch response.result {
                case .success(let value):
                    print("updated watchlist successfully")

                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    func fetchWatchlistAgain(completion: @escaping () -> Void) {
        let urlString = "\(self.host)/api/watchlist"
        
        AF.request(urlString).validate().responseJSON { [weak self] response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let resultsArray = json.array ?? []
                    
                    do {
                        let json = JSON(resultsArray)
                        self?.watchlist = json.arrayValue
                        completion()
                    } catch {
                        print("Decoding error: \(error)")
                        self?.errorMessage = "Error: Could not parse JSON"
                    }

                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteFromWatchlist(id: String) {
        let urlString = "\(host)/api/watchlist/\(id)"

        AF.request(urlString, method: .delete).response { response in
            switch response.result {
            case .success:
                print("delete success: \(id)")
            case .failure(let error):
                print("delete error")
            }
        }
    }
}

