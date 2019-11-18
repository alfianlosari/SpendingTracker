//
//  LogListView.swift
//  SpendingTracker
//
//  Created by Alfian Losari on 16/11/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import SwiftUI
import Firebase

struct LogListView: View {
    
    @State var isFilterListExpanded = false
    @State var isSortByListExpanded = false
    @State var isSortOrderListExpanded = false
    
    @State var isShowingCreateModalForm = false
    @State var isShowingEditModalForm = false
    
    @State var selectedFilters: Set<Category> = [] {
        didSet { self.refresh() }
    }
    @State var selectedSortOrder = SortOrder.descending {
        didSet { self.refresh() }
    }
    @State var selectedSortFilter = SortFilter.date {
        didSet { self.refresh() }
    }
    
    @ObservedObject var repository = LogRepositoryViewModel()
    
    let filters = Category.allCases
    let sortOrders = SortOrder.allCases
    let sortFilters = SortFilter.allCases
    
    var body: some View {
        NavigationView {
            List {
                VStack {
                    AccordionButton(title: "Filters: \(self.selectedFilters.isEmpty ? "All" : "(\(self.selectedFilters.count))")", isExpanded: self.isFilterListExpanded) {
                        self.isFilterListExpanded.toggle()
                    }
                    
                    if self.isFilterListExpanded {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(self.filters) { category in
                                    Button(action: {
                                        if self.selectedFilters.contains(category) {
                                            self.selectedFilters.remove(category)
                                        } else {
                                            self.selectedFilters.insert(category)
                                        }
                                    }) {
                                        Text(category.rawValue.capitalized)
                                            .bordered(isSelected: self.selectedFilters.contains(category), selectedTextColor: .white, defaultTextColor: .blue, selectedBackgroundColor: .blue, defaultBackgroundColor: .clear)
                                    }
                                }
                            }
                            .padding(.top, 1)
                            .padding(.bottom, 4)
                            .padding(.horizontal, 1)
                        }
                    }
                }
                
                VStack {
                    AccordionButton(title: "Sort By: \(selectedSortFilter.rawValue.capitalized)", isExpanded: self.isSortByListExpanded) {
                        self.isSortByListExpanded.toggle()
                    }
                    
                    if self.isSortByListExpanded {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(self.sortFilters) { sort in
                                    Button(action: {
                                        self.selectedSortFilter = sort
                                    }) {
                                        Text(sort.rawValue.capitalized)
                                            .bordered(isSelected: self.selectedSortFilter == sort, selectedTextColor: .white, defaultTextColor: .blue, selectedBackgroundColor: .blue, defaultBackgroundColor: .clear)
                                    }
                                }
                            }
                            .padding(.top, 1)
                            .padding(.bottom, 4)
                            .padding(.horizontal, 1)
                        }
                    }
                }
                
                VStack {
                    AccordionButton(title: "Order By: \(selectedSortOrder.rawValue.capitalized)", isExpanded: self.isSortOrderListExpanded) {
                        self.isSortOrderListExpanded.toggle()
                    }
                    
                    if self.isSortOrderListExpanded {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(self.sortOrders) { sort in
                                    Button(action: {
                                        self.selectedSortOrder = sort
                                    }) {
                                        Text(sort.rawValue.capitalized)
                                            .bordered(isSelected: self.selectedSortOrder == sort, selectedTextColor: .white, defaultTextColor: .blue, selectedBackgroundColor: .blue, defaultBackgroundColor: .clear)
                                    }
                                }
                            }
                            .padding(.top, 1)
                            .padding(.bottom, 4)
                            .padding(.horizontal, 1)
                        }
                    }
                }
                
                ForEach(self.repository.logs) { log in
                    Button(action: {
                        self.isShowingEditModalForm = true
                    }) {
                        LogRow(spendingLog: log)
                    }.sheet(isPresented: self.$isShowingEditModalForm) {
                        LogEditView(editedSpending: log) {
                            self.update(log: $0)
                        }
                    }
                }
                .onDelete { (indexes) in
                    self.delete(at: indexes)
                }
            }
                
            .navigationBarTitle("Spending Tracker")
            .navigationBarItems(leading: Button(action: {
                try? Auth.auth().signOut()
            }, label: {
                Image(systemName: "person.circle")
                Text("Logout")
            }), trailing:  Button(action: {
                self.isShowingCreateModalForm = true
            }, label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add")
                }
            }).sheet(isPresented: self.$isShowingCreateModalForm, content: {
                LogEditView(editedSpending: nil) { (log) in
                    self.repository.add(log: log)
                }
            })).onAppear {
                self.refresh()
            }.onDisappear {
                self.repository.removeListener()
            }
        }
    }
    
    private func refresh() {
        self.repository.observeLogs(selectedFilters: self.selectedFilters, selectedSortOrder: self.selectedSortOrder, selectedSortFilter: self.selectedSortFilter)
    }
    
    private func delete(at indexes: IndexSet) {
        for index in indexes {
            self.repository.delete(log: self.repository.logs[index])
        }
    }
    
    private func update(log: SpendingLog) {
        self.repository.update(log: log)
    }
}

struct FilterListSelectionRow: View {
    
    @Binding var isExpanded: Bool
    @Binding var selectedFilters: Set<Category>
    
    let filters: [Category]
    
    var body: some View {
        VStack {
            AccordionButton(title: "Filters: \(self.selectedFilters.isEmpty ? "All" : "(\(self.selectedFilters.count))")", isExpanded: self.isExpanded) {
                self.isExpanded.toggle()
            }
            
            if self.isExpanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(self.filters) { category in
                            Button(action: {
                                if self.selectedFilters.contains(category) {
                                    self.selectedFilters.remove(category)
                                } else {
                                    self.selectedFilters.insert(category)
                                }
                            }) {
                                Text(category.rawValue.capitalized)
                                    .bordered(isSelected: self.selectedFilters.contains(category), selectedTextColor: .white, defaultTextColor: .blue, selectedBackgroundColor: .blue, defaultBackgroundColor: .clear)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
    
    
}

struct AccordionButton: View {
    
    let title: String
    let isExpanded: Bool
    let action: () -> ()
    
    var body: some View {
        
        HStack {
            Text(title)
            Spacer()
            Button(action: {
                self.action()
            }) {
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(self.isExpanded ? 90 : 0))
            }
        }.padding(.vertical, 4)
            .foregroundColor(.blue)
        
    }
    
}


struct LogRow: View {
    
    var spendingLog: SpendingLog
    
    static private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.isLenient = true
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(spendingLog.name)
                    .font(.headline)
                HStack {
                    Text(spendingLog.category.rawValue.capitalized)
                        .font(.caption)
                    Text("(\(LogRow.dateFormatter.string(from: spendingLog.date)))")
                        .font(.caption)
                }
            }
            Spacer()
            Text(LogRow.currencyFormatter.string(from: NSNumber(value: spendingLog.amount)) ?? "")
                .font(.body)
        }
    }
    
}

struct LogListView_Previews: PreviewProvider {
    static var previews: some View {
        LogListView()
    }
}
