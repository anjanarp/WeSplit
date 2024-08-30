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
    var id = UUID()
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
                    Section("Add People") {
                        TextField("Person Name", text: $newPersonName)
                            .padding(.vertical, 5)
                        
                        Button(action: addPerson) {
                            Text("Add Person")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.vertical, 5)
                        
                        // display list of added people
                        if !people.isEmpty {
                            Section("People") {  // This nested section could be the issue
                                ForEach(people) { person in
                                    Text(person.name)
                                        .font(.headline)
                                }
                            }
                        }
                    }

                    Section("Add new item") {
                        if people.isEmpty {
                            Text("Please add people first before adding items")
                                .foregroundColor(.red)
                        } else {
                            TextField("Item Name", text: $newItemName)
                                .padding(.vertical, 5)
                            
                            TextField("Item Price", value: $newItemPrice, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                .keyboardType(.decimalPad)
                                .focused($amountIsFocused)
                                .padding(.vertical, 5)
                            
                            // select people who ate the item
                            Section("Select People") {
                                ForEach(people) { person in
                                    Toggle(person.name, isOn: Binding(get: {
                                        selectedPeople.contains(person)
                                    }, set: { isSelected in
                                        if isSelected {
                                            selectedPeople.insert(person)
                                        } else {
                                            selectedPeople.remove(person)
                                        }
                                    }))
                                }
                            }
                            Button(action: addItem) {
                                Text("Add Item")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    // section to display added items
                    Section("Items") {
                        if items.isEmpty {
                            Text("No items added yet.")
                        } else {
                            ForEach(items) { item in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .font(.headline)
                                        Text(item.price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                        Text("Shared by: \(item.people.map(\.name).joined(separator: ", "))")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    // pushes the icons to the right side
                                    Spacer()
                                    
                                    // edit button UI
                                    Button(action: {
                                        editItem(item)
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    
                                    // delete button UI
                                    Button(action: {
                                        deleteItem(item)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
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
                            
                            Text("Tip Amount: \(tipPercentage)%")
                                .padding(.top, 5)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    // display for total per person
                    Section("Amount per Person") {
                        let totals = calculateTotalsPerPerson()
                         
                        ForEach(people) { person in
                            if let total = totals[person] {
                                HStack {
                                    Text(person.name)
                                        .font(.headline)
                                    Spacer()
                                    Text(total, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                        .font(.body)
                                }
                            }
                        }
                    }
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
    func addPerson() {
        // only add the person if the name is not empty
        guard !newPersonName.isEmpty else {return}
        
        let newPerson = Person(name: newPersonName)
        people.append(newPerson)
        
        // clear the input field
        newPersonName = ""
    }
    
    // function to add a new item to the list
    func addItem() {
        // create a new item with the current input
        let newItem = Item(name: newItemName, price: newItemPrice, people: Array(selectedPeople))
        
        // add the new item to the items array
        items.append(newItem)
        
        // reset the input fields
        newItemName = ""
        newItemPrice = 0.0
        selectedPeople.removeAll()
        
        // dismiss the keyboard
        amountIsFocused = false
    }
    
    func editItem(_ item: Item) {
        // Find the index of the item in the array
        if let index = items.firstIndex(where: {$0.id == item.id}) {
            newItemName = items[index].name
            newItemPrice = items[index].price
            selectedPeople = Set(items[index].people)
            
            // remove the item from the array so that it can be updated
            items.remove(at: index)
        }
    }
    
    func deleteItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
        }
    }
    
    func calculateTotalsPerPerson() -> [Person: Double] {
        var totals = [Person: Double]()
        
        for item in items {
            let share = item.price / Double(item.people.count)
            for person in item.people {
                totals[person, default: 0.0] += share
            }
        }
        
        let totalBill = totals.values.reduce(0, +)
        let totalWithTip = totalBill + (totalBill * Double(tipPercentage) / 100)
        let tipRatio = totalWithTip / totalBill
        
        for person in totals.keys {
            totals[person]! *= tipRatio
        }
        
        return totals
    }
}

#Preview {
    ContentView()
}
