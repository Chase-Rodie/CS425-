//
//  ShoppingListView.swift
//  Fit Pantry
//
//  Created by Heather Amistani on 3/2/25.
//

import SwiftUI
import Firebase

struct ShoppingListView: View {
    @StateObject private var shoppingList = ShoppingList()
    @State private var newItem: String = ""
    @State private var isMenuOpen = false
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    List {
                        ForEach(shoppingList.items, id: \.self) { item in
                            HStack {
                                Text(item)
                                Spacer()
                                Button(action: {
                                    if let index = shoppingList.items.firstIndex(of: item) {
                                        shoppingList.removeItem(at: index)
                                    }
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

                            shoppingList.addItem(trimmedItem)
                            newItem = ""
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .font(.title)
                        }
                        .padding(.trailing)
                    }
                    .padding()
                }
                .background(Color("LighterColor").ignoresSafeArea())
                .navigationTitle("Shopping List")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.black)
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            shoppingList.loadFromFirestore()
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }

            if isMenuOpen {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    isMenuOpen = false
                                }
                            }

                        HamburgerMenuView()
                            .frame(width: geometry.size.width * 0.7)
                            .transition(.move(edge: .leading))
                    }
                }
            }
        }
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView()
    }
}
