//
//  AutocompleteView.swift
//  StockApp
//
//  Created by Boda Song on 4/3/24.
//
import SwiftUI

class SearchModel: ObservableObject {
    @Published var searchText: String = ""
}

struct AutocompleteView: View {
    @Binding var searchText: String
    @StateObject private var viewModel = AutocompleteViewModel()

    var body: some View {
        VStack {
            if let results = viewModel.data?.result {
                List(results.filter { !$0.symbol.contains(".") }, id: \.symbol) { item in
                    NavigationLink(destination: DetailView(symbol: item.symbol)) {
                        VStack(alignment: .leading) {
                            Text(item.symbol)
                                .font(.headline)
                            Text(item.description)
                                .font(.subheadline)
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
            } else {
                Text("Loading...")
            }
        }
        .onChange(of: searchText) { newValue in
            viewModel.fetchData(searchText: newValue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
