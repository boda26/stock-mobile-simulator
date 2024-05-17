//
//  DetailViewModel.swift
//  StockApp
//
//  Created by Boda Song on 4/3/24.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import WebKit

class DetailViewModel: ObservableObject {
//    private let host = "http://127.0.0.1:3000"
    private let host = "https://stockapp26-421000.wl.r.appspot.com"
    @Published var profileData: Profile?
    @Published var isLoadingProfile = false
    @Published var errorMessage: String?
    @Published var quoteData: Quote?
    @Published var isLoadingQuote = false
    @Published var isLoadingHourlyData = false
    @Published var hourlyData: [HourlyDataModel] = []
    private var isPositive = false
    @Published var isLoadingHistoryData = false
    @Published var historyData: [HistoryDataModel] = []
    @Published var peersData: Array<String>?
    @Published var isLoadingPeers = false
    @Published var isLoadingInsights = false
    @Published var totalMSPR: Double? = 0.0
    @Published var totalChange: Int? = 0
    @Published var posMSPR: Double? = 0.0
    @Published var posChange: Int? = 0
    @Published var negMSPR: Double? = 0.0
    @Published var negChange: Int? = 0
    @Published var isLoadingTrend = false
    @Published var trendData: [TrendDataModel] = []
    @Published var trendJS: String?
    @Published var hourlyJS: String?
    @Published var historyJS: String?
    @Published var isLoadingEarnings = false
    @Published var earningsData: [EarningsDataModel] = []
    @Published var earningsJS: String?
    @Published var isLoadingNews = false
    @Published var newsData: [NewsDataModel] = []
    @Published var isInWatchlist = false
    @Published var watchlistId: String = ""
    @Published var isLoadingWatchlist = false
    @Published var isLoadingPortfolio = false
    @Published var isInPortfolio = false
    @Published var portfolioId: String = ""
    @Published var quantity: Int = 0
    @Published var totalCost: Double = 0.0
    @Published var avgCost: Double = 0.0
    @Published var balance: Double = 0.0
    @Published var balanceId: String = ""
    @Published var isLoadingBalance = false
    
    func fetchProfileData(forSymbol symbol: String) {
        guard !isLoadingProfile, profileData == nil else {
            return
        }
        
        isLoadingProfile = true
        errorMessage = nil
        
        let urlString = "\(host)/api/profile/\(symbol)"
        
        AF.request(urlString).validate().responseJSON { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoadingProfile = false
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self?.profileData = Profile(json: json)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    
    }
    
    func fetchQuoteData(forSymbol symbol: String) {
        guard !isLoadingQuote, quoteData == nil else {
            return
        }
        isLoadingQuote = true
        errorMessage = nil
        let urlString = "\(host)/api/quote/\(symbol)"
        
        AF.request(urlString).validate().responseJSON { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoadingQuote = false
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self?.quoteData = Quote(json: json)
                    if self?.quoteData?.dp ?? 0.0 > 0 {
                        self!.isPositive = true
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func fetchHourlyData(forSymbol symbol: String) {
        guard !isLoadingHourlyData, hourlyData.isEmpty else {
            return
        }

        isLoadingHourlyData = true
        let urlString = "\(host)/api/hourly/\(symbol)"

        AF.request(urlString).responseData { [weak self] response in
            DispatchQueue.main.async {
                defer { self?.isLoadingHourlyData = false }

                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let resultsArray = json["results"].array ?? []
                    
                    do {
                        let decodedData = try resultsArray.map { try $0.rawData() }.map { try JSONDecoder().decode(HourlyDataModel.self, from: $0) }
                        
                        self?.hourlyData = decodedData

                        let timestamps = decodedData.map { $0.t }
                        let closePrices = decodedData.map { $0.c }
                        let timestampsJson = try JSONEncoder().encode(timestamps)
                        let closePricesJson = try JSONEncoder().encode(closePrices)
                        let timestampsString = String(data: timestampsJson, encoding: .utf8) ?? "[]"
                        let closePricesString = String(data: closePricesJson, encoding: .utf8) ?? "[]"
                        var lineColor = "red"
                        if (self?.isPositive == true) {
                            lineColor = "green"
                        }
                        self?.hourlyJS = "createHourlyChart('\(timestampsString)', '\(closePricesString)', '\(symbol)', '\(lineColor)');"
                        
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
    
    func fetchHistoryData(forSymbol symbol: String) {
        guard !isLoadingHistoryData, historyData.isEmpty else {
            return
        }

        isLoadingHistoryData = true
        let urlString = "\(host)/api/history/\(symbol)"

        AF.request(urlString).responseData { [weak self] response in
            DispatchQueue.main.async {
                defer { self?.isLoadingHistoryData = false }

                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let resultsArray = json["results"].array ?? []
                    
                    do {
                        let decodedData = try resultsArray.map { try $0.rawData() }.map { try JSONDecoder().decode(HistoryDataModel.self, from: $0) }
                        
                        self?.historyData = decodedData
                        
                        let timestamps = decodedData.map { $0.t }
                        let openPrices = decodedData.map { $0.o }
                        let closePrices = decodedData.map { $0.c }
                        let highPrices = decodedData.map { $0.h }
                        let lowPrices = decodedData.map { $0.l }
                        let volumes = decodedData.map { $0.v }
                        
                        let timestampsJson = try JSONEncoder().encode(timestamps)
                        let openPricesJson = try JSONEncoder().encode(openPrices)
                        let closePricesJson = try JSONEncoder().encode(closePrices)
                        let highPricesJson = try JSONEncoder().encode(highPrices)
                        let lowPricesJson = try JSONEncoder().encode(lowPrices)
                        let volumesJson = try JSONEncoder().encode(volumes)
                        
                        let timestampsString = String(data: timestampsJson, encoding: .utf8) ?? "[]"
                        let openPricesString = String(data: openPricesJson, encoding: .utf8) ?? "[]"
                        let closePricesString = String(data: closePricesJson, encoding: .utf8) ?? "[]"
                        let highPricesString = String(data: highPricesJson, encoding: .utf8) ?? "[]"
                        let lowPricesString = String(data: lowPricesJson, encoding: .utf8) ?? "[]"
                        let volumesString = String(data: volumesJson, encoding: .utf8) ?? "[]"
                        
                        self?.historyJS = "createHistoryChart('\(timestampsString)', '\(openPricesString)', '\(closePricesString)', '\(highPricesString)', '\(lowPricesString)', '\(volumesString)', '\(symbol)');"
                        
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
    
    func fetchPeersData(forSymbol symbol: String) {
        isLoadingPeers = true
        let urlString = "\(host)/api/peers/\(symbol)"
        AF.request(urlString).validate().responseJSON { response in
            DispatchQueue.main.async {
                self.isLoadingPeers = false
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self.peersData = json.arrayValue.map { $0.stringValue }
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchInsightsData(forSymbol symbol: String) {
        totalChange = 0
        totalMSPR = 0.0
        posChange = 0
        negChange = 0
        posMSPR = 0.0
        negMSPR = 0.0
        isLoadingInsights = true
        let urlString = "\(host)/api/insight/\(symbol)"
        AF.request(urlString).validate().responseJSON { response in
            DispatchQueue.main.async {
                self.isLoadingInsights = false
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let dataArray = json["data"].arrayValue
                    
                    for item in dataArray {
                        let change = item["change"].intValue
                        let mspr = item["mspr"].doubleValue
                        self.totalChange! += change
                        self.totalMSPR! += mspr
                        if (change > 0) {
                            self.posChange! += change
                        } else {
                            self.negChange! += change
                        }
                        if (mspr > 0.0) {
                            self.posMSPR! += mspr
                        } else {
                            self.negMSPR! += mspr
                        }
                    }
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchTrendData(forSymbol symbol: String) {
        guard !isLoadingTrend, trendData.isEmpty else {
            return
        }

        isLoadingTrend = true
        let urlString = "\(host)/api/trend/\(symbol)"

        AF.request(urlString).responseData { [weak self] response in
            DispatchQueue.main.async {
                defer { self?.isLoadingTrend = false }

                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let resultsArray = json.array ?? []
                    
                    do {
                        let decodedData = try resultsArray.map { try $0.rawData() }.map { try JSONDecoder().decode(TrendDataModel.self, from: $0) }
                        
                        self?.trendData = decodedData
                        
                        let date = decodedData.map {$0.period}
                        let strongBuy = decodedData.map {$0.strongBuy}
                        let buy = decodedData.map {$0.buy}
                        let hold = decodedData.map {$0.hold}
                        let sell = decodedData.map {$0.sell}
                        let strongSell = decodedData.map {$0.strongSell}
                        
                        let dateJson = try JSONEncoder().encode(date)
                        let strongBuyJson = try JSONEncoder().encode(strongBuy)
                        let buyJson = try JSONEncoder().encode(buy)
                        let holdJson = try JSONEncoder().encode(hold)
                        let sellJson = try JSONEncoder().encode(sell)
                        let strongSellJson = try JSONEncoder().encode(strongSell)
                        
                        let dateString = String(data: dateJson, encoding: .utf8) ?? "[]"
                        let strongBuyString = String(data: strongBuyJson, encoding: .utf8) ?? "[]"
                        let buyString = String(data: buyJson, encoding: .utf8) ?? "[]"
                        let holdString = String(data: holdJson, encoding: .utf8) ?? "[]"
                        let sellString = String(data: sellJson, encoding: .utf8) ?? "[]"
                        let strongSellString = String(data: strongSellJson, encoding: .utf8) ?? "[]"
                        
                        self?.trendJS = "createTrendChart('\(dateString)', '\(strongBuyString)', '\(buyString)', '\(holdString)', '\(sellString)', '\(strongSellString)');"
                        
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
    
    func fetchEarningsData(forSymbol symbol: String) {
        guard !isLoadingEarnings, earningsData.isEmpty else {
            return
        }

        isLoadingEarnings = true
        let urlString = "\(host)/api/earnings/\(symbol)"

        AF.request(urlString).responseData { [weak self] response in
            DispatchQueue.main.async {
                defer { self?.isLoadingEarnings = false }

                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let resultsArray = json.array ?? []
                    
                    do {
                        let decodedData = try resultsArray.map { try $0.rawData() }.map { try JSONDecoder().decode(EarningsDataModel.self, from: $0) }
                        
                        self?.earningsData = decodedData
                        
                        let periods = decodedData.map {$0.period}
                        let surprise = decodedData.map {$0.surprise}
                        let actual = decodedData.map {$0.actual}
                        let estimate = decodedData.map {$0.estimate}
                        
                        let periodsJson = try JSONEncoder().encode(periods)
                        let surpriseJson = try JSONEncoder().encode(surprise)
                        let actualJson = try JSONEncoder().encode(actual)
                        let estimateJson = try JSONEncoder().encode(estimate)
                        
                        let periodsString = String(data: periodsJson, encoding: .utf8) ?? "[]"
                        let surpriseString = String(data: surpriseJson, encoding: .utf8) ?? "[]"
                        let actualString = String(data: actualJson, encoding: .utf8) ?? "[]"
                        let estimateString = String(data: estimateJson, encoding: .utf8) ?? "[]"
                        
                        self?.earningsJS = "createEarningsChart('\(periodsString)', '\(surpriseString)', '\(actualString)', '\(estimateString)');"
                        
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
    
    func fetchNewsData(forSymbol symbol: String) {
        guard !isLoadingNews, newsData.isEmpty else {
            return
        }

        isLoadingNews = true
        let urlString = "\(host)/api/news/\(symbol)"

        AF.request(urlString).responseData { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoadingNews = false

                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let resultsArray = json.array ?? []
                    
                    do {
                        let decodedData = try resultsArray.map { try $0.rawData() }.map { try JSONDecoder().decode(NewsDataModel.self, from: $0) }
                        let filteredData = decodedData.filter { !$0.image.isEmpty }.prefix(20)
                        self?.newsData = Array(filteredData)
                        
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
    
    func fetchFromWatchlist(forSymbol symbol: String) {
        isLoadingWatchlist = true
        let urlString = "\(host)/api/watchlist"
        AF.request(urlString).validate().responseJSON { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoadingWatchlist = false
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let resultsArray = json.array ?? []
                    do {
                        let json = JSON(resultsArray)
                        let watchlist = json.arrayValue
                        
                        if let item = resultsArray.first(where: { $0["symbol"].stringValue == symbol }) {
                            self?.isInWatchlist = true
                            self?.watchlistId = item["_id"].stringValue
                        }
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
    
    func onWatchlistClicked() {
        if (isInWatchlist == true) {
            isInWatchlist = false
            let urlString = "\(host)/api/watchlist/\(self.watchlistId)"

            AF.request(urlString, method: .delete).response { response in
                switch response.result {
                case .success:
                    print("Successfully removed from watchlist: \(self.watchlistId)")
                case .failure(let error):
                    print("delete error")
                }
            }
            
        } else {
            isInWatchlist = true
            
            let urlString = "\(host)/api/watchlist"
            
            guard let ticker = profileData?.ticker, let name = profileData?.name, let latestPrice = quoteData?.c, let change = quoteData?.d, let changePercent = quoteData?.dp else {
                print("Ticker or name is nil.")
                return
            }
            
            let data = [
                "symbol": ticker,
                "name": name,
                "latestPrice": latestPrice,
                "change": change,
                "changePercent": changePercent
            ] as [String : Any]
            
            print(data)
            
            AF.request(urlString, method: .post, parameters: data,  encoding: JSONEncoding.default).responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("Successfully added to watchlist!")
                case .failure(let error):
                    print("Error while performing POST request: \(error)")
                }
            }
        }
    }
    
    func fetchFromPortfolio(forSymbol symbol: String) {
        isInPortfolio = false
        
        isLoadingPortfolio = true
        let urlString = "\(host)/api/portfolio"
        AF.request(urlString).validate().responseJSON { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoadingPortfolio = false
                switch response.result {
                case .success(let data):
                    let json = JSON(data)
                    let resultsArray = json.array ?? []
                    do {
                        let json = JSON(resultsArray)
                        let portfolio = json.arrayValue
                        
                        if let item = resultsArray.first(where: { $0["symbol"].stringValue == symbol }) {
                            self?.isInPortfolio = true
                            self?.portfolioId = item["_id"].stringValue
                            self?.quantity = item["quantity"].intValue
                            self?.totalCost = item["totalCost"].doubleValue
                            self?.avgCost = item["totalCost"].doubleValue / item["quantity"].doubleValue

                        }
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
    
    func fetchBalance() {
        isLoadingBalance = true
        let urlString = "\(host)/api/balance"
        
        AF.request(urlString).validate().responseJSON { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoadingBalance = false
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    self!.balance = json[0]["balance"].doubleValue
                    self!.balanceId = json[0]["_id"].stringValue
                    print(self!.balance)
                    print(self!.balanceId)
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
