//
//  Settings.swift
//  Valeo
//
//  Created by Lori Hill on 09.01.21.
//

import SwiftUI

/// View to represent all aviable settings to a user.
struct Settings: View {
    
    @EnvironmentObject var authentication: AuthenticationViewModel
    @State var showWarning = false
    
    var body: some View {
        List {
            Section(header: Text("Profil")) {
                NavigationLink(
                    destination: PersonalData(),
                    label: {
                        HStack {
                            Text("Persönliche Daten")
                            Spacer()
                            Image(systemName: "person.fill")
                        }
                    })
                NavigationLink(
                    destination: DiarySettings(),
                    label: {
                        HStack {
                            Text("Tagebucheinstellungen")
                            Spacer()
                            Image(systemName: "house.fill")
                        }
                    })
            }
            .listStyle(SidebarListStyle())
            
            Section(header: Text("Systemeinstellungen")) {
                NavigationLink(
                    destination: AccountSettings(),
                    label: {
                        HStack {
                            Text("Kontoeinstellungen")
                            Spacer()
                            Image(systemName: "gear")
                        }
                    })
                
                NavigationLink(
                    destination: NotificationSettings(),
                    label: {
                        HStack {
                            Text("Benachrichtigungseinstellungen")
                            Spacer()
                            Image(systemName: "bell.fill")
                        }
                    })
                
//                NavigationLink(
//                    destination: NotificationSettings(),
//                    label: {
//                        HStack {
//                            Text("Automatisches Tracking")
//                            Spacer()
//                            Image(systemName: "arrow.left.arrow.right.circle")
//                        }
//                    })
            }
            Section(header: Text("Sonstiges"), footer: HStack {
                Spacer()
                VStack {
                    Button(action: { authentication.logout() }, label: {
                        Text("Abmelden")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.all, 10)
                            .overlay(Capsule().stroke(Color.gray, lineWidth: 3))
                            .background(Color.black)
                            .clipShape(Capsule())
                    })
                    .padding(.top, 30)
                    
                    Text("v\(UIApplication.appVersion ?? "0.0.0")" )
                        .font(.caption)
                }
                Spacer()
            }
            .padding(.top, 75)) {
                NavigationLink(
                    destination: AGB(),
                    label: {
                        // MARK: Benötigt? Informieren, dass dies ein Prototyp ist und die Informationen nur für interene Zwecke zum verbessern der Qualität verwendet werden. Es werden keine Daten weitergegeben, abgesehen von der Nutzung von Google Analytics und Google Firebase (vergleiche mit Jodel AGB)
                        HStack {
                            Text("Datenschutzerklärung")
                            Spacer()
                            Image(systemName: "doc")
                        }
                    })
                
                NavigationLink(
                    destination: Licences(),
                    label: {
                        // MARK: Firebase Lizenz, für mögliche Dokumente ?
                        HStack {
                            Text("Lizenzen")
                            Spacer()
                            Image(systemName: "archivebox")
                        }
                    })
                
//                NavigationLink(
//                    destination: Sources(),
//                    label: {
//                        // MARK: Quellen für Kalorienbedarfrechnung, etc.
//                        HStack {
//                            Text("Quellen")
//                            Spacer()
//                            Image(systemName: "doc.plaintext")
//                        }
//                    })
                
//                NavigationLink(
//                    destination: InviteFriends(),
//                    label: {
//                        HStack {
//                            Text("Freunde einladen")
//                            Spacer()
//                            Image(systemName: "person.2.fill")
//                        }
//                    })
            }
        }
        .listStyle(GroupedListStyle())
    }
    
    
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
