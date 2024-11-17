# Product Management App

A Swift-based iOS app for managing products, including listing, adding, and searching for products. This app is built using Swift and SwiftUI in an MVVM architecture, with Core Data for offline functionality and modern iOS development practices.

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Acknowledgements](#acknowledgements)

---

## Features

- **Product Listing**: Browse products with smooth scrolling and offline caching.
- **Search Functionality**: Quickly find products with a search feature.
- **Add Product**: Add new products through a form, including optional image selection.
- **Favorites**: Mark products as favorites for quick access.
- **Offline Support**: Products are cached locally using Core Data for offline access.
- **Network Monitoring**: Detects connectivity changes to handle online/offline states.
- **MVVM Architecture**: Uses MVVM to separate logic, enhance modularity, and improve code maintainability.

---

## Requirements

- **Xcode 15 or later**
- **iOS 16.0 or later**
- **Swift 5.5 or later**

---

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Devashish2106/AssignmentSwipe
   cd AssignmentSwipe
   ```

2. **Open the project in Xcode**:
   ```bash
   open AssignmentSwipeApp.xcodeproj
   ```

3. **Run the app**:
   Select a target device or simulator, then press `Cmd + R` to build and run the app.

---

## Usage

1. **Product Listing**: View the main product listing screen after launching the app.
2. **Search**: Use the search bar at the top to filter products by name.
3. **Add Product**: Navigate to the "Add Product" screen using the "Add" button.
4. **Image Selection**: Select an image from a predefined set or from your device.
5. **Offline Mode**: The app will automatically use cached data when offline, ensuring seamless access.

---

## Project Structure

- **ContentView.swift**: Main entry point of the app, including navigation between views.
- **AddProductView.swift**: Form for adding new products, with fields for product name, price, type, and optional image selection.
- **NetworkManager.swift**: Handles API requests for fetching and posting product data.
- **NetworkMonitor.swift**: Monitors the device's network status to enable offline support.
- **Persistence.swift**: Manages Core Data stack and handles local caching of product data.

---

## Acknowledgements

- **Core Data**: Used for local persistence and offline support.
- **SwiftUI**: Combined to handle UI layout and navigation.
