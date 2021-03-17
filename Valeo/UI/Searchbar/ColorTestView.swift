//
//  ColorTestView.swift
//  Valeo
//
//  Created by Lori Hill on 26.02.21.
//

import SwiftUI

struct ColorTestView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var pickerSelection: AmountSizes = .gramms
    
    var body: some View {
        NavigationView {
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Text("Searchbar")
                        .frame(width: geometry.size.width, height: 100, alignment: .center)
                    
//                    HStack {
//                        Picker(pickerSelection.id, selection: $pickerSelection) {
//                            ForEach(AmountSizes.allCases) { size in
//                                Text(size.id)
//                                    .tag(size)
//                            }
//                        }
//                    }
//                    .contentShape(Rectangle())
//                    .frame(width: 200, height: 34, alignment: .center)
//                    .background(Color.red.onTapGesture {
//                        self.pickerSelection = .bigPortion
//                    })
//                    .pickerStyle(MenuPickerStyle())
//                    .foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
//                    .overlay(
//                    RoundedRectangle(cornerRadius: 5)
//                    .stroke(Color(.systemGray4), lineWidth: 0.5))
                    
                    CustomMenuPicker(selection: $pickerSelection, label: Text("Test")) {
                        ForEach(AmountSizes.allCases) { size in
                            Text(size.id)
                                .tag(size)
                        }
                    }
                    .frame(width: 100, height: 100, alignment: .center)
                    
                }
                .background(Color(.systemGray6))
            }
            .navigationBarTitle("Title",
                                displayMode: .inline)
            
        }
    }
}

struct ColorTestView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ColorTestView()
            ColorTestView()
                .environment(\.colorScheme, .dark)
        }
    }
}

struct CustomMenuPicker<Label, SelectionValue, Content>: View where Label: View, SelectionValue: Hashable, Content: View {
    
    @State var expand = false
    
    let label: Label
    @Binding var selection: SelectionValue
    let content: Content
    
    public init(selection: Binding<SelectionValue>, label: Label, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.label = label
        self.content = content()
    }
    
    var body: some View {
        VStack {
            HStack {
                self.label
            }
            .onTapGesture {
                self.expand.toggle()
            }
            
            if self.expand {
                self.content
            }
        }
    }
    
}
