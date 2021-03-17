//
//  MainSearchbarView.swift
//  Valeo
//
//  Created by Lori Hill on 09.01.21.
//

import SwiftUI
import InstantSearch

/// Search view for nutrients.
/// Dynamic full text search in algolia.
struct MainSearchbarView: View {
        
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var navigator: Navigator
    @EnvironmentObject var user: UserViewModel
    
    let searcher: SingleIndexSearcher =
        SingleIndexSearcher(appID: ApplicationID(rawValue: APIKeys.algoliaAppId),
                            apiKey: APIKey(rawValue: APIKeys.algoliaApiKey),
                            indexName: "nutrient_search")
    let filterState: FilterState  = .init()
    let hitsInteractor: HitsInteractor<NutrientBase> = .init()
    @ObservedObject var hitListController = HitsListController()
    
    @State var searchtext = ""
    
    init() {
        hitsInteractor.connectSearcher(searcher)
        hitsInteractor.connectFilterState(filterState)
        hitsInteractor.connectController(hitListController)
    }
    
    var body: some View {
        
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.title)

                    TextField("Search", text: self.$searchtext)
                        .frame(height: 40)
                        .foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                    if self.searchtext != "" {
                        Button(action: {
                            self.searchtext = ""
                            self.hitListController.allNutrients = []
                        }){
                            Image(systemName: "xmark.circle")
                                .font(.title)
                                .foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                        }
                        .foregroundColor(.black)
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .keyboardType(.default)
                .background(self.colorScheme == .light ? Color.white : Color.black)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(self.colorScheme == .light ?
                                            Color.clear : Color(.systemGray2)))
                .padding(.top, 5)
                .padding(.horizontal, 10)
                
                List {
                    Section (header: Text("Suchergebnisse")) {
                        ForEach(hitListController.allNutrients, id: \.nutrientId) { i in
                            NavigationLink(destination: NutrientView(by: i, mealType: navigator.curentMealType, user: self.user.user!)){
                                Text(i.name)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .onChange(of: self.searchtext, perform: { value in
                    if value != "" {
                        self.searcher.query = self.searchtext
                        self.searcher.search()
                    } else {
                        self.hitListController.allNutrients = []
                    }
                })
                .navigationBarTitle(self.navigator.curentMealType.rawValue,
                                    displayMode: .inline)
                .navigationBarItems(leading:
                                        Button(action: {
                                            self.hideSearchbar()
                                        }) {
                                            Image(systemName: "xmark")
                                                .foregroundColor(self.colorScheme == .light ? Color.black : Color.white)
                                                .font(.title)
                                                .padding(.leading, 10)})
            }
            .background(self.colorScheme == .light ? Color(.systemGray6) : Color.clear)
        }
    }
    
    private func hideSearchbar() {
        withAnimation {
            self.navigator.currentView = .main
        }
    }
    
}

struct MainSearchbarView_Previews: PreviewProvider {
    static var previews: some View {
        MainSearchbarView()
    }
}
