import SwiftUI
import WebKit
import Kingfisher

struct DetailView: View {
    let symbol: String
    @StateObject private var viewModel = DetailViewModel()
    @State private var selectedTab = "Hourly"
    @State private var selectedArticle: NewsDataModel?
    @State private var addToWatchListAlert = false
    @State private var removedFromWatchlistAlert = false
    @State private var showTradingView = false
    
    var body: some View {
        Group {
            if viewModel.isLoadingProfile || viewModel.isLoadingQuote || viewModel.isLoadingHourlyData || viewModel.isLoadingHistoryData || viewModel.isLoadingPeers || viewModel.isLoadingInsights || viewModel.isLoadingTrend || viewModel.isLoadingEarnings || viewModel.isLoadingNews || viewModel.isLoadingWatchlist {
                ProgressView("Fetching data")
            } else if let profileData = viewModel.profileData,
                      let quoteData = viewModel.quoteData,
                      let peersData = viewModel.peersData,
                      let totalChange = viewModel.totalChange,
                      let totalMSPR = viewModel.totalMSPR,
                      let posChange = viewModel.posChange,
                      let negChange = viewModel.negChange,
                      let posMSPR = viewModel.posMSPR,
                      let negMSPR = viewModel.negMSPR,
                      let trendJS = viewModel.trendJS,
                      let hourlyJS = viewModel.hourlyJS,
                      let historyJS = viewModel.historyJS,
                      let earningsJS = viewModel.earningsJS {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(profileData.ticker)
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 5)
                            .padding(.bottom, 10)
                        Text(profileData.name)
                            .font(.subheadline)
                            .foregroundStyle(Color.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 10)
                        
                        HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                            Text("$\(quoteData.c, specifier: "%.2f")")
                                .font(.title)
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .padding(.trailing, 10)
                            Image(systemName: quoteData.d > 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.title3)
                                .foregroundColor(quoteData.d > 0 ? .green : .red)
                            Text("$\(quoteData.d, specifier: "%.2f") (\(quoteData.dp, specifier: "%.2f")%)")
                                .font(.title3)
                                .foregroundColor(quoteData.d > 0 ? .green : .red)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding([.leading, .trailing], 30)

                    TabView(selection: $selectedTab) {
                        HourlyWebView(
                            htmlFilename: "index",
                            javascript: hourlyJS
                        )
                        .tag("Hourly")
                        .tabItem {
                            Label("Hourly", systemImage: "chart.xyaxis.line")
                        }
                        
                        HourlyWebView(
                            htmlFilename: "historyChart",
                            javascript: historyJS
                        )
                        .tag("History")
                        .tabItem {
                            Label("History", systemImage: "clock.fill")
                        }
                    }
                    .frame(minHeight: 400)
                    .padding(.bottom, 20)

                    VStack(alignment: .leading) {
                        Text("Portfolio")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                if (viewModel.isInPortfolio == true) {
                                    let change = quoteData.c - viewModel.avgCost
                                    
                                    Text("Shares Owned: \(viewModel.quantity)")
                                        .font(.subheadline)
                                        .padding(.top, 5)
                                        .padding(.bottom, 5)
                                    
                                    Text("Avg.Cost/Share: $\(viewModel.avgCost, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .padding(.top, 5)
                                        .padding(.bottom, 5)
                                    
                                    Text("Total Cost: $\(viewModel.totalCost, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .padding(.top, 5)
                                        .padding(.bottom, 5)
                                    
                                    HStack {
                                        Text("Change:")
                                            .font(.subheadline)
                                            .foregroundColor(.black)

                                        Text("$\(change, specifier: "%.2f")")
                                            .foregroundColor(change > 0 ? .green : (change < 0 ? .red : .black))
                                            .font(.subheadline)
                                    }
                                    .padding(.vertical, 5)
                                    
                                    HStack {
                                        Text("Market Value:")
                                            .font(.subheadline)
                                            .foregroundColor(.black)

                                        Text("$\(quoteData.c, specifier: "%.2f")")
                                            .foregroundColor(change > 0 ? .green : (change < 0 ? .red : .black))
                                            .font(.subheadline)
                                    }
                                    .padding(.vertical, 5)

                                } else {
                                    Text("You have 0 shares of \(symbol). Start trading!")
                                        .font(.subheadline)
                                        .padding(.top, 5)
                                        .padding(.bottom, 5)
                                }
                            }
                            Spacer()
                            VStack {
                                Button(action: {
                                    showTradingView = true
                                }) {
                                    Text("Trade")
                                        .padding(.horizontal, 50)
                                        .padding(.vertical, 15)
                                        .foregroundColor(.white)
                                        .background(.green)
                                        .cornerRadius(50)
                                        
                                }
                            }
                            
                        }
                    }
                    .padding([.leading, .trailing], 30)
                    .padding(.bottom)

                    VStack(alignment: .leading) {
                        Text("Stats")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 0) {
                            (Text("High Price: ")
                                .fontWeight(.semibold)
                             + Text("\(quoteData.h, specifier: "%.2f")"))
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            (Text("Open Price: ")
                                .fontWeight(.semibold)
                             + Text("\(quoteData.o, specifier: "%.2f")"))
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        
                        HStack(spacing: 0) {
                            (Text("Low Price: ")
                                .fontWeight(.semibold)
                             + Text("\(quoteData.l, specifier: "%.2f")"))
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            (Text("Prev. Close: ")
                                .fontWeight(.semibold)
                             + Text("\(quoteData.pc, specifier: "%.2f")"))
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                    }
                    .padding([.leading, .trailing], 30)
                    .padding(.bottom)

                    VStack(alignment: .leading) {
                        Text("About")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 0) {
                            Text("IPO Start Date: ")
                                .fontWeight(.semibold)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(profileData.ipo)")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        
                        HStack(spacing: 0) {
                            Text("Industry: ")
                                .fontWeight(.semibold)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(profileData.finnhubIndustry)")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        
                        HStack(spacing: 0) {
                            Text("Webpage: ")
                                .fontWeight(.semibold)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Link(destination: URL(string: profileData.weburl) ?? URL(string: "https://www.google.com")!) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    Text(profileData.weburl)
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        
                        HStack(spacing: 0) {
                            Text("Company Peers: ")
                                .fontWeight(.semibold)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(peersData.filter { !$0.contains(".") }, id: \.self) { peer in
                                        NavigationLink(destination: DetailView(symbol: peer)) {
                                            Text(peer + ",")
                                                .fontWeight(.regular)
                                                .font(.subheadline)
                                                .foregroundStyle(Color.blue)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        
                    }
                    .padding([.leading, .trailing], 30)
                    .padding(.bottom)

                    VStack(alignment: .leading) {
                        Text("Insights")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Insider Sentiments")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        HStack {
                            Text("\(profileData.name)")
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("MSPR")
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("Change")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .padding(.top, 5)
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            // "$\(String(format: "%.2f", viewModel.netWorth))"
                            Text("\(String(format: "%.2f", totalMSPR))")
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("\(String(totalChange))")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .font(.subheadline)
                        .fontWeight(.regular)
                        
                        Divider()
                        
                        HStack {
                            Text("Positive")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("\(String(format: "%.2f", posMSPR))")
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("\(String(posChange))")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .font(.subheadline)
                        .fontWeight(.regular)
                        
                        Divider()
                        
                        HStack {
                            Text("Negative")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("\(String(format: "%.2f", negMSPR))")
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("\(String(negChange))")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .font(.subheadline)
                        .fontWeight(.regular)
                        
                        Divider()
                    }
                    .padding([.leading, .trailing], 30)
                    .padding(.bottom)

                    TrendWebView(
                        htmlFilename: "TrendChart",
                        javascript: trendJS
                    )
                    .frame(height: 350)

                    TrendWebView(
                        htmlFilename: "EarningsChart",
                        javascript: earningsJS
                    )
                    .frame(height: 350)
                    
                    VStack(alignment: .leading) {
                        Text("News")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        
                        ForEach(Array(viewModel.newsData.enumerated()), id: \.element.id) { index, article in
                            if index == 0 {
            
                                VStack {
                                    KFImage(URL(string: article.image))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 350, height: 200)
                                        .clipped()
                                        .cornerRadius(8)
                                        .overlay(RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                    
                                    HStack {
                                        Text(article.source)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                        
                                        Text(article.timeAgo)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.bottom, 2)
                                    
                                    Text(article.headline)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .lineLimit(3)
                                        .frame(alignment: .leading)
                                    
                                }
                                .padding()
                                .padding(.horizontal)
                                .onTapGesture {
                                    self.selectedArticle = article
                                }
                                
                                Divider()
                                
                            } else {
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(article.source)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .fontWeight(.semibold)
                                            
                                            Spacer()
                                            
                                            Text(article.timeAgo)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Text(article.headline)
                                            .font(.headline)
                                            .lineLimit(3)
                                    }
                                    
                                    KFImage(URL(string: article.image))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(10)
                                }
                                .padding()
                                .onTapGesture {
                                    self.selectedArticle = article
                                }
                            }
                        }
                    }
                }
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                Text("No data available.")
            }
        }
        .onAppear {
            viewModel.fetchProfileData(forSymbol: symbol)
            viewModel.fetchQuoteData(forSymbol: symbol)
            viewModel.fetchHourlyData(forSymbol: symbol)
            viewModel.fetchPeersData(forSymbol: symbol)
            viewModel.fetchInsightsData(forSymbol: symbol)
            viewModel.fetchTrendData(forSymbol: symbol)
            viewModel.fetchHistoryData(forSymbol: symbol)
            viewModel.fetchEarningsData(forSymbol: symbol)
            viewModel.fetchNewsData(forSymbol: symbol)
            viewModel.fetchFromWatchlist(forSymbol: symbol)
            viewModel.fetchFromPortfolio(forSymbol: symbol)
            viewModel.fetchBalance()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.onWatchlistClicked()
                    if viewModel.isInWatchlist {
                        addToWatchListAlert = true // Show the alert
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            addToWatchListAlert = false // Hide the alert after 2 seconds
                        }
                    }
                    if (viewModel.isInWatchlist == false) {
                        removedFromWatchlistAlert = true // Show the alert
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            removedFromWatchlistAlert = false // Hide the alert after 2 seconds
                        }
                    }
                }) {
                    Image(systemName: viewModel.isInWatchlist ? "plus.circle.fill" : "plus.circle")
                }
            }
        }
        .sheet(item: $selectedArticle, onDismiss: {
        }) { article in
            NewsDetailSheetView(article: $selectedArticle)
        }
        .sheet(isPresented: $showTradingView, onDismiss: {
            viewModel.fetchFromPortfolio(forSymbol: symbol)
            viewModel.fetchBalance()
        }) {
            TradingView(detailViewModel: viewModel, showingSheet: $showTradingView)
        }
        .overlay(
            VStack {
                Spacer() // Pushes everything below it to the bottom of the available space
                if addToWatchListAlert {
                    Text("Added \(symbol) to Watchlist")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(20)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                if removedFromWatchlistAlert {
                    Text("Removed \(symbol) from Watchlist")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(20)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
        )
    }
}

