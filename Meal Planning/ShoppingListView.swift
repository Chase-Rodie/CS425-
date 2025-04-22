//
//  ShoppingListView.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 3/2/25.

import SwiftUI
import Firebase

struct ShoppingListView: View {
    @StateObject private var shoppingList = ShoppingList()
    @State private var newItem: String = ""
    @State private var newQuantity: String = ""
    @State private var showQuantityPrompt = false
    @State private var pendingItemName: String = ""
    @State private var selectedUnit: String = "g"
    
    let units = ["g", "oz", "cup", "tbsp", "tsp", "slice", "can", "loaf", "lbs", "kg", "ml", "L", "gal"]

    
    private static let decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(Array(shoppingList.items.enumerated()), id: \.1.id) { index, item in
                        HStack {
//                            Text("\(item.name) (\(item.quantity, specifier: "%.1f"))")
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                
                                HStack {
                                    Text("Qty:")
                                        .font(.subheadline)

                                    TextField("0", value: Binding(
                                        get: { item.quantity },
                                        set: { newValue in
                                            shoppingList.updateQuantity(for: item.id, newQuantity: newValue)
                                        }
                                    ), formatter: ShoppingListView.decimal)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 60)
                                }
                            }
                            Spacer()
                            Button(action: {
                                shoppingList.removeItem(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .onAppear {
                    shoppingList.loadFromFirestore()
                }

                HStack {
                    TextField("Add new item", text: $newItem)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)

                    Button(action: {
                        let trimmedItem = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedItem.isEmpty else { return }
                        pendingItemName = trimmedItem
                        newItem = ""
                        showQuantityPrompt = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color("BackgroundColor"))
                            .font(.title)
                    }
                    .padding(.trailing)
                }
                .padding()
            }
            .navigationTitle("Shopping List")
        }
        .sheet(isPresented: $showQuantityPrompt) {
            VStack(spacing: 20) {
                Text("Enter quantity for \(pendingItemName)")
                    .font(.headline)

                TextField("Quantity", text: $newQuantity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)

                Picker("Unit", selection: $selectedUnit) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit).tag(unit)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity)
                HStack {
                    Button("Cancel") {
                        newQuantity = ""
                        showQuantityPrompt = false
                    }
                    .foregroundColor(Color("Orange"))

                    Spacer()

                    Button("Add") {
                        if let quantity = Double(newQuantity) {
                            shoppingList.addItem(name: pendingItemName, quantity: quantity, unit: selectedUnit)
                        }
                        newQuantity = ""
                        pendingItemName = ""
                        selectedUnit = "g"
                        showQuantityPrompt = false
                    }
                    .foregroundColor(Color("Navy"))
                }
                .padding()
            }
            .padding()
        }
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView()
    }
}
