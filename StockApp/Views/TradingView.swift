//
//  TradingView.swift
//  StockApp
//
//  Created by Boda Song on 4/20/24.
//

import SwiftUI

struct TradingView: View {
    @ObservedObject var detailViewModel = DetailViewModel()
    @StateObject private var tradingViewModel = TradingViewModel()
    @Binding var showingSheet: Bool
    @State private var notEnoughShareToSellMessage = false
    @State private var notEnoughMoneyToBuyMessage = false
    @State private var invalidAmountToBuy = false
    @State private var invalidAmountToSell = false
    @State private var showBuySuccessSheet = false
    @State private var showSellSuccessSheet = false
    
    
    var body: some View {
        NavigationView {
            VStack {

                // Title
                Text("Trade \(detailViewModel.profileData!.name) shares")
                    .font(.title3)
                    .padding()
                    .fontWeight(.semibold)
                
                VStack {
                    HStack(alignment: .bottom) {
                        VStack {
                            Spacer()
                            
                            TextField(
                                "0",
                                text: $tradingViewModel.inputQuantity
                            )
                            .keyboardType(.numberPad)
                            .font(.system(size: 60))
                            
                        }
                        VStack {
                            Spacer()
                            
                            Text("Shares")
                                .font(.title2)
                                .fontWeight(.regular)
                                .padding(.bottom)
                        }
                    }
                    .frame(height: 250)
                    
                    VStack(alignment: .trailing) {
                        Text("x $\(String(format: "%.2f", detailViewModel.quoteData!.c))/share = $\(String(format: "%.2f", tradingViewModel.totalPrice))")
                            .font(.headline)
                            .fontWeight(.regular)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Spacer()
                    }
                    .frame(height: 150)
                }
                .padding()
                
                // Available funds
                Text("$\(String(format: "%.2f", detailViewModel.balance)) available to buy \(detailViewModel.profileData!.ticker)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding()
                    
                // Buy and Sell buttons
                HStack(spacing: 20) {
                    Button("Buy") {
                        if let inputQuantity = Int(tradingViewModel.inputQuantity), inputQuantity <= 0 {
                            invalidAmountToBuy = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                invalidAmountToBuy = false
                            }
                        } else if detailViewModel.balance < tradingViewModel.totalPrice {
                            notEnoughMoneyToBuyMessage = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                notEnoughMoneyToBuyMessage = false
                            }
                        } else {
                            tradingViewModel.onBuyButtonClicked()
                            showBuySuccessSheet = true
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(30)
                        
                    Button("Sell") {
                        if let inputQuantity = Int(tradingViewModel.inputQuantity), inputQuantity <= 0 {
                            invalidAmountToSell = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                invalidAmountToSell = false
                            }
                        } else if let inputQuantity = Int(tradingViewModel.inputQuantity), inputQuantity > detailViewModel.quantity {
                            notEnoughShareToSellMessage = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                notEnoughShareToSellMessage = false
                            }
                        } else {
                            tradingViewModel.onSellButtonClicked()
                            showSellSuccessSheet = true
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(30)
                }
                .padding()
                    
                Spacer()
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSheet = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showBuySuccessSheet, onDismiss: {
//                showingSheet = false
            }) {
                BuySuccessView(quantity: tradingViewModel.inputQuantity, symbol: detailViewModel.profileData!.ticker, showBuySuccessView: $showBuySuccessSheet, showingSheet: $showingSheet)
            }
            .sheet(isPresented: $showSellSuccessSheet, onDismiss: {
//                showingSheet = false
            }) {
                SellSuccessView(quantity: tradingViewModel.inputQuantity, symbol: detailViewModel.profileData!.ticker, showSellSuccessView: $showSellSuccessSheet, showingSheet: $showingSheet)
            }
            .overlay(
                VStack {
                    Spacer() 
                    if notEnoughMoneyToBuyMessage {
                        Text("Not enough money to buy")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(20)
                            .transition(.scale.combined(with: .opacity))
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    if notEnoughShareToSellMessage {
                        Text("Not enough share to sell")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(20)
                            .transition(.scale.combined(with: .opacity))
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    if invalidAmountToBuy {
                        Text("Cannot buy non-positive shares")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(20)
                            .transition(.scale.combined(with: .opacity))
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    if invalidAmountToSell {
                        Text("Cannot sell non-positve shares")
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
            .onAppear {
                tradingViewModel.symbol = detailViewModel.profileData!.ticker
                tradingViewModel.name = detailViewModel.profileData!.name
                tradingViewModel.sharePrice = detailViewModel.quoteData!.c
                tradingViewModel.balance = detailViewModel.balance
                tradingViewModel.balanceId = detailViewModel.balanceId
                tradingViewModel.currentQuantity = detailViewModel.quantity
                tradingViewModel.stockId = detailViewModel.portfolioId
                tradingViewModel.totalCost = detailViewModel.totalCost
            }
        }
    }
}
