//
//  FilterView.swift
//  Sprite Fonts
//
//  Created by Jayden Irwin on 2021-02-16.
//

import SwiftUI

struct FilterView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var filterTags: Set<FontFamily.Tag>
    @Binding var excludeTags: Set<FontFamily.Tag>
    @Binding var minCapHeight: Int
    @Binding var maxCapHeight: Int
    @Binding var smallCapHeight: Bool
    @Binding var mediumCapHeight: Bool
    @Binding var largeCapHeight: Bool
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(FontFamily.Tag.allCases) { tag in
                        HStack {
                            Text(tag.rawValue)
                            Spacer()
                            Button {
                                if excludeTags.contains(tag) {
                                    excludeTags.remove(tag)
                                } else {
                                    excludeTags.insert(tag)
                                    if filterTags.contains(tag) {
                                        filterTags.remove(tag)
                                    }
                                }
                            } label: {
                                Image(systemName: excludeTags.contains(tag) ? "xmark.circle.fill" : "xmark.circle")
                                    .imageScale(.large)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(excludeTags.contains(tag) ? Color(UIColor.systemRed) : Color.accentColor)
                            Button {
                                if filterTags.contains(tag) {
                                    filterTags.remove(tag)
                                } else {
                                    filterTags.insert(tag)
                                    if excludeTags.contains(tag) {
                                        excludeTags.remove(tag)
                                    }
                                }
                            } label: {
                                Image(systemName: filterTags.contains(tag) ? "checkmark.circle.fill" : "checkmark.circle")
                                    .imageScale(.large)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .foregroundColor(filterTags.contains(tag) ? Color(UIColor.systemGreen) : Color.accentColor)
                        }
                    }
                }
                Section(header: Text("Cap Height")) {
                    HStack {
                        Button("1-6 px") {
                            smallCapHeight.toggle()
                            refreshCapHeightLimits()
                        }
                        .buttonStyle(FilterButtonStyle(isSelected: smallCapHeight))
                        Button("7-9 px") {
                            mediumCapHeight.toggle()
                            refreshCapHeightLimits()
                        }
                        .buttonStyle(FilterButtonStyle(isSelected: mediumCapHeight))
                        Button("10+ px") {
                            largeCapHeight.toggle()
                            refreshCapHeightLimits()
                        }
                        .buttonStyle(FilterButtonStyle(isSelected: largeCapHeight))
                    }
                    .padding(.vertical, 6)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        filterTags.removeAll()
                        excludeTags.removeAll()
                        smallCapHeight = false
                        mediumCapHeight = false
                        largeCapHeight = false
                        refreshCapHeightLimits()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    func refreshCapHeightLimits() {
        if !smallCapHeight, !mediumCapHeight, !largeCapHeight {
            minCapHeight = 1
            maxCapHeight = Int.max
            return
        }
        if smallCapHeight {
            minCapHeight = 1
        } else if mediumCapHeight {
            minCapHeight = 7
        } else {
            minCapHeight = 10
        }
        if largeCapHeight {
            maxCapHeight = Int.max
        } else if mediumCapHeight {
            maxCapHeight = 9
        } else {
            maxCapHeight = 6
        }
    }
    
}

struct FilterButtonStyle: ButtonStyle {
    
    var isSelected = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(idealWidth: .infinity, maxWidth: .infinity, minHeight: 44, idealHeight: 44, maxHeight: 44)
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(isSelected ? Color(UIColor.systemGreen) : Color.accentColor, lineWidth: 2))
            .foregroundColor(isSelected ? Color(UIColor.systemGreen) : Color.accentColor)
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(filterTags: .constant([]), excludeTags: .constant([]), minCapHeight: .constant(0), maxCapHeight: .constant(100), smallCapHeight: .constant(false), mediumCapHeight: .constant(false), largeCapHeight: .constant(false))
    }
}
