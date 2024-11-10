//
//  AddProductView.swift
//  AssignmentSwipe
//
//  Created by Devashish Ghanshani on 10/11/24.
//

import SwiftUI
import PhotosUI

struct AddProductView: View {
    @StateObject private var viewModel = AddProductViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    var onProductAdded: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Product Details")) {
                        TextField("Product Name", text: $viewModel.productName)
                        
                        Picker("Product Type", selection: $viewModel.productType) {
                            ForEach(["Product", "Service"], id: \.self) { type in
                                Text(type)
                            }
                        }
                        
                        TextField("Price", text: $viewModel.price)
                            .keyboardType(.decimalPad)
                        TextField("Tax", text: $viewModel.tax)
                            .keyboardType(.decimalPad)
                    }

                    Section(header: Text("Select Image")) {
                        Button(action: {
                            isImagePickerPresented.toggle()
                        }) {
                            Text("Choose Image")
                        }
                        .sheet(isPresented: $isImagePickerPresented) {
                            ImagePicker(image: $selectedImage)
                        }

                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                
                VStack {
                    Button("Add Product") {
                        viewModel.addProduct {
                            onProductAdded()  // Call the callback when product is added successfully
                            dismiss()
                        }
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .disabled(viewModel.isAddingProduct)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)

                    Button("Cancel") {
                        if !viewModel.isAddingProduct {
                            dismiss()
                        }
                    }
                    .foregroundColor(.red)
                    .padding(.top)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Add Product")
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Info"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
