//
//  Autocomplete.swift
//  StockApp
//
//  Created by Boda Song on 4/1/24.
//
import SwiftUI
import Alamofire
import SwiftyJSON

class AutocompleteViewModel: ObservableObject {
    @Published var data: AutocompleteData?
    private var workItem: DispatchWorkItem?

    func fetchData(searchText: String) {
        
//        let host = "http://127.0.0.1:3000"
        let host = "https://stockapp26-421000.wl.r.appspot.com"
        
        self.data = nil

        workItem?.cancel()

        workItem = DispatchWorkItem { [weak self] in
            
            let urlString = "\(host)/api/autocomplete/\(searchText)"
                    
            AF.request(urlString).responseData { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        do {
                            let decodedData = try JSONDecoder().decode(AutocompleteData.self, from: data)
                            self?.data = decodedData
                        } catch {
                            print("Decoding failed: \(error)")
                        }
                    case .failure(let error):
                        print("Network request failed: \(error.localizedDescription)")
                    }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem!)
    }
}
