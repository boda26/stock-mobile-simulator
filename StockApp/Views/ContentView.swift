//
//  ContentView.swift
//  StockApp
//
//  Created by Boda Song on 3/31/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var searchModel: SearchModel
    @State private var showSearchResults = false
    @EnvironmentObject private var viewModel: ContentViewModel
    let currentDate = Date()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Fetching data")
                } else {
                    List {
                        Section {
                            HStack(alignment: .top) {
                                Text(currentDate, style: .date)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                        
                        Section {
                            HStack {
                                VStack {
                                    Text("Net Worth")
                                        .font(.title3)
                                        .fontWeight(.regular)
                                    Text("$\(String(format: "%.2f", viewModel.netWorth))")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                                
                                Spacer()
                                VStack {
                                    Text("Cash Balance")
                                        .font(.title3)
                                        .fontWeight(.regular)
                                    Text("$\(String(format: "%.2f", viewModel.balance))")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                            }
                            
                            ForEach(viewModel.portfolioList, id: \.dictionaryValue["_id"]!.stringValue) { item in
                                NavigationLink(destination: DetailView(symbol: item["symbol"].rawValue as! String)) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(item["symbol"].stringValue)
                                                .font(.title3)
                                                .fontWeight(.bold)
                                            Text("\(item["quantity"].intValue) shares")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            let price = item["latestPrice"].double ?? 0.0
                                            let quantity = item["quantity"].int ?? 0
                                            let totalCost = item["totalCost"].double ?? 0.0
                                            let avgCost = totalCost / Double(quantity)
                                            let currentValue = price * Double(quantity)
                                            let change = (price - avgCost) * Double(quantity)
                                            let percentChange = (change / totalCost) * 100.00
                                            Text("$\(currentValue, specifier: "%.2f")")
                                                .font(.title3)
                                                .fontWeight(.bold)
                                            
                                            HStack {
                                                Image(systemName: change > 0 ? "arrow.up.right" : (change < 0 ? "arrow.down.right" : "minus"))
                                                    .font(.title3)
                                                    .foregroundColor(change > 0 ? .green : (change < 0 ? .red : .secondary))
                                                
                                                Text("$\(change, specifier: "%.2f") (\(percentChange, specifier: "%.2f")%)")
                                                    .font(.subheadline)
                                                    .foregroundColor(change > 0 ? .green : (change < 0 ? .red : .secondary))
                                            }
                                        }
                                    }
                                }
                            }
                            .onMove(perform: movePortfolioItem)
                            
                        } header: { Text("PORTFOLIO") }
                        
                        Section {
                            ForEach(viewModel.watchlist, id: \.dictionaryValue["_id"]!.stringValue) { item in
                                NavigationLink(destination: DetailView(symbol: item["symbol"].rawValue as! String)) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(item["symbol"].stringValue)
                                                .font(.title3)
                                                .fontWeight(.bold)
                                            Text(item["name"].stringValue)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            let change = item["change"].double ?? 0.0
                                            
                                            Text("$\(item["latestPrice"].doubleValue, specifier: "%.2f")")
                                                .font(.title3)
                                                .fontWeight(.bold)
                                            
                                            HStack {
                                                Image(systemName: change > 0 ? "arrow.up.right" : (change < 0 ? "arrow.down.right" : "minus"))
                                                    .font(.title3)
                                                    .foregroundColor(change > 0 ? .green : (change < 0 ? .red : .secondary))
                                                
                                                Text("$\(item["change"].doubleValue, specifier: "%.2f") (\(item["changePercent"].doubleValue, specifier: "%.2f")%)")
                                                    .font(.subheadline)
                                                    .foregroundColor(change > 0 ? .green : (change < 0 ? .red : .secondary))
                                            }
                                        }
                                    }
                                }
                            }
                            .onMove(perform: moveWatchlistItem)
                            .onDelete(perform: deleteFromWatchlist)
                        } header: {
                            Text("FAVORITES")
                        }
                        
                        Section {
                            VStack {
                                Link(destination: URL(string: "https://finnhub.io/") ?? URL(string: "https://finnhub.io/")!) {
                                    Text("Powered by FinnHub.io")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(maxWidth:.infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        }
                        
                    }
                    .listStyle(.insetGrouped)
                    .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                    .navigationTitle("Stocks")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        // If you have any toolbar items, add them here
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                    }
                    .searchable(text: $searchModel.searchText)
                    .overlay(
                        VStack {
                            if !searchModel.searchText.isEmpty {
                                AutocompleteView(searchText: $searchModel.searchText)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .zIndex(1)
                            }
                        },
                        alignment: .top
                    )
                }
            }
            .onAppear {
                viewModel.fetchHomeData()
                searchModel.searchText = ""
            }
        }
    }
    
    func moveWatchlistItem(from source: IndexSet, to destination: Int) {
        viewModel.watchlist.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteFromWatchlist(at offsets: IndexSet) {
        let idsToDelete = offsets.map { viewModel.watchlist[$0]["_id"].stringValue }
        viewModel.watchlist.remove(atOffsets: offsets)
        idsToDelete.forEach { id in
            viewModel.deleteFromWatchlist(id: id)
        }
    }
    
    func movePortfolioItem(from source: IndexSet, to destination: Int) {
        viewModel.portfolioList.move(fromOffsets: source, toOffset: destination)
    }
}

extension Date {
    func formattedDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: self)
    }
}

