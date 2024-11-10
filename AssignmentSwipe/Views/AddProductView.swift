//
//  AddProductView.swift
//  AssignmentSwipe
//
//  Created by Devashish Ghanshani on 10/11/24.
//

import SwiftUI

struct AddProductView: View {
    @StateObject private var viewModel = AddProductViewModel()
    
    var body: some View {
        Form {
            Section(header: Text("Product Details")) {
                TextField("Product Name", text: $viewModel.productName)
                TextField("Product Type", text: $viewModel.productType)
                TextField("Price", text: $viewModel.price)
                    .keyboardType(.decimalPad)
                TextField("Tax", text: $viewModel.tax)
                    .keyboardType(.decimalPad)
            }
            
            Button("Add Product") {
                viewModel.addProduct()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(8)
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Info"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .navigationTitle("Add Product")
    }
}

