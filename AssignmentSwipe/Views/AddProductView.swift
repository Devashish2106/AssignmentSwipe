//
//  AddProductView.swift
//  AssignmentSwipe
//
//  Created by Devashish Ghanshani on 10/11/24.
//

import SwiftUI

struct AddProductView: View {
    @StateObject private var viewModel = AddProductViewModel()
    @Environment(\.dismiss) var dismiss  // Dismiss the sheet

    var body: some View {
        ZStack {
            VStack {
                Form {
                    Section(header: Text("Product Details")) {
                        TextField("Product Name", text: $viewModel.productName)
                        TextField("Product Type", text: $viewModel.productType)
                        TextField("Price", text: $viewModel.price)
                            .keyboardType(.decimalPad)
                        TextField("Tax", text: $viewModel.tax)
                            .keyboardType(.decimalPad)
                    }
                }

                Spacer()
                
                // Centering the Add Product button
                Button("Add Product") {
                    viewModel.addProduct {
                        dismiss()  // Dismiss the sheet after the product is successfully added
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
                .disabled(viewModel.isAddingProduct)  // Disable while adding product
                .frame(maxWidth: .infinity)
                .padding()
            }

            // Cancel Button at the top-right corner
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        if !viewModel.isAddingProduct {  // Only dismiss if not adding product
                            dismiss()
                        }
                    }) {
                        Text("Cancel")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .navigationTitle("Add Product")
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Info"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
