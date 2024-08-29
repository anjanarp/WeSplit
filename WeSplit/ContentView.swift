//
//  ContentView.swift
//  WeSplit
//
//  Created by Anjana Rajamani on 8/2/24.
//

import SwiftUI

// Person struct for the concerned attributes of each person
struct Person: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var amountOwed: Double = 0.0
}

// Item struct to keep track of food item attributes
struct Item: Identifiable {
    var id = UUID() // unique identifier for each item
    var name: String
    var price: Double
    var people: [Person]
}


struct ContentView: View {
    // state variables for "equal" split
    @State private var checkAmount = 0.0
    @State private var numberOfPeople = 2
    @State private var tipPercentage = 20
    @FocusState private var amountIsFocused: Bool
    // state to track selected split method
    @State private var splitMethod = "Equal"
    
    // additional state variables for "itemized" split
    @State private var items = [Item]()
    @State private var newItemName = ""
    @State private var newItemPrice = 0.0
    @State private var selectedPeople = Set<Person>()
    
    @State private var people = [Person]()
    @State private var newPersonName = ""
    
    // struct stored properties
    let tipPercentages = [10, 15, 20, 25]
    let splitMethods = ["Equal", "Itemized"]
    
    // struct computed properties
    var totalWithTip: Double {
        let tip = Double(tipPercentage) / 100 * checkAmount
        let total = checkAmount + tip
        return total
    }
    
    var totalPerPersonEqual: Double {
        // calculate total per person here
        let peopleCount = Double(numberOfPeople + 2)
        let tipSelection = Double(tipPercentage)
        let tipValue = checkAmount / 100 * tipSelection
        let grandTotal = checkAmount + tipValue
        let amountPerPerson = grandTotal / peopleCount
        return amountPerPerson
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // segmented control for selecting the split method
                Section {
                    Picker("split method", selection: $splitMethod) {
                        ForEach(splitMethods, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(5)
                
                if splitMethod == "Equal" {
                    Section("Bill Amount") {
                        TextField("Amount", value: $checkAmount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                            .keyboardType(.decimalPad)
                            .focused($amountIsFocused)
                    }
                    Section {
                        Picker("Number of people", selection: $numberOfPeople) {
                            ForEach(2..<100) {
                                Text("\($0) people")
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                    Section("How much tip do you want to leave?") {
                        VStack {
                            Picker("Tip percentage", selection: $tipPercentage) {
                                ForEach(0..<101, id: \.self) {
                                    Text($0, format: .percent)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.top, 5)
                            
                            Text("Tip Amount: \(tipPercentage)")
                                .padding(.top, 5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    Section("Total amount with tip") {
                        Text(totalWithTip, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    }
                    Section("Amount per person") {
                        Text(totalPerPersonEqual, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    }
                } else {
                    // Placeholder for Itemized split view
                    Text("Itemized Split View - Coming Soon!")
                    
                    
                }
            }
            
            
            .toolbar {
                if amountIsFocused {
                    Button("Done") {
                            amountIsFocused = false
                    }
                }
            }
            .navigationTitle("Split the bill")
        }
    }
}

#Preview {
    ContentView()
}
