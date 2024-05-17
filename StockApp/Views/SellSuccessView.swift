import SwiftUI

struct SellSuccessView: View {
    var quantity: String = ""
    var symbol: String = ""
    @Binding var showSellSuccessView: Bool
    @Binding var showingSheet: Bool
    
    var body: some View {
        ZStack {
            Color.green.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                VStack {
                    Text("Congratulations!")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("You have successfully sold \(quantity) shares of \(symbol)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.top, 5)
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                
                Spacer()
                
                Button(action: {
                    showSellSuccessView = false
                    showingSheet = false
                }) {
                    Text("Done")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 100)
                        .padding(.vertical, 15)
                        .foregroundColor(.green)
                        .background(Color.white)
                        .cornerRadius(50)
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 40)
            }
        }
    }
}


