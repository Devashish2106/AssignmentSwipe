//
//  AddProductView.swift
//  AssignmentSwipe
//
//  Created by Devashish Ghanshani on 10/11/24.
//

import SwiftUI
import PhotosUI

import SwiftUI
import PhotosUI

struct AddProductView: View {
    @StateObject private var viewModel = AddProductViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var isImagePickerPresented = false
    var onProductAdded: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Product Details")) {
                        TextField("Product Name", text: $viewModel.productName)
                        
                        Picker("Product Type", selection: $viewModel.productType) {
                            Text("Select Type").tag("")
                            ForEach(["Product", "Service"], id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        
                        TextField("Price", text: $viewModel.price)
                            .keyboardType(.decimalPad)
                        TextField("Tax", text: $viewModel.tax)
                            .keyboardType(.decimalPad)
                    }

                    Section(header: Text("Product Image")) {
                        Button(action: {
                            isImagePickerPresented.toggle()
                        }) {
                            HStack {
                                Image(systemName: "photo")
                                Text(viewModel.selectedImage == nil ? "Add Image" : "Change Image")
                            }
                        }
                        
                        if let image = viewModel.selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .clipped()
                        }
                    }
                }
                
                Button(action: {
                    viewModel.addProduct {
                        onProductAdded()
                        dismiss()
                    }
                }) {
                    if viewModel.isAddingProduct {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Add Product")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(viewModel.isAddingProduct)
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Add Product")
            .navigationBarItems(
                leading: Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            )
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $viewModel.selectedImage)
            }
            .alert("Message", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
}

// Preview provider for SwiftUI canvas
struct AddProductView_Previews: PreviewProvider {
    static var previews: some View {
        AddProductView(onProductAdded: {})
    }
}
