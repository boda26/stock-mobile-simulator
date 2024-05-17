//
//  NewsDetailView.swift
//  StockApp
//
//  Created by Boda Song on 4/18/24.
//

import SwiftUI

struct NewsDetailSheetView: View {
    @Binding var article: NewsDataModel?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    if let article = article {
                        Text(article.source)
                            .font(.title)
                        
                        Text("Published: \(article.timeAgo)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        Text(article.headline)
                            .font(.headline)
                            .padding(.top)
                        
                        Text(article.summary)
                            .font(.footnote)
                        
                        VStack(alignment: .leading) {
                            Text("For more details, click ")
                                .font(.footnote)
                                .foregroundColor(.secondary) +
                            Text("here")
                                .foregroundColor(.blue)
                                .font(.footnote)
                        }
                        .onTapGesture {
                            if let url = URL(string: article.url), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            } else {
                                let fallbackUrl = URL(string: "https://www.google.com")!
                                UIApplication.shared.open(fallbackUrl, options: [:], completionHandler: nil)
                            }
                        }
                        .padding(.bottom)
                        
                        HStack {
                            Button(action: {
                                let urlString = "https://twitter.com/intent/tweet?text=\(article.headline)&url=\(article.url)"

                                if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                } else {
                                    let fallbackUrl = URL(string: "https://www.x.com")!
                                    UIApplication.shared.open(fallbackUrl, options: [:], completionHandler: nil)
                                }
                            }) {
                                Image("x-logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                            }
                            
                            Button(action: {
                                let urlString = "https://www.facebook.com/sharer/sharer.php?u=\(article.url)&amp;src=sdkpreparse"
                                if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                } else {
                                    let fallbackUrl = URL(string: "https://www.facebook.com")!
                                    UIApplication.shared.open(fallbackUrl, options: [:], completionHandler: nil)
                                }
                            }) {
                                Image("fb-logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                            }
                        }
                        
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: Button(action: {
                self.article = nil // This sets the article to nil, effectively dismissing the view
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
            })
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

