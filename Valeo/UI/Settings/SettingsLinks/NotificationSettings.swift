//
//  NotificationSettings.swift
//  Valeo
//
//  Created by Lori Hill on 10.01.21.
//

import SwiftUI
import UserNotifications

struct NotificationSettings: View {
    
    @State var notificationsEnabled = false
    @State var isAllowedToShowNotifications = false
    @State var isLoading = false
                
    var body: some View {
        
        List(0 ..< 1 ) { item in
            HStack {
                Toggle(isOn: $notificationsEnabled, label: {
                    Text("Push Benachrichtigungen")
                })
                .disabled(isLoading)
            }
        }
        .onAppear {
            self.notificationsEnabled = UIApplication.shared.isRegisteredForRemoteNotifications
            getNotificationState()
        }
        .onChange(of: self.notificationsEnabled, perform: { value in
            if value {
                enableNotifications()
            } else {
                disableNotifications()
            }
        })
    }
    
    
    private func getNotificationState(){
        isLoading = true
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                self.isAllowedToShowNotifications = true
            case .denied:
                self.isAllowedToShowNotifications = false
            case .notDetermined:
                self.isAllowedToShowNotifications = false
            default:
                self.isAllowedToShowNotifications = false
            }
            self.isLoading = false
            return
        }
    }
    
    private func disableNotifications() {
        if self.notificationsEnabled {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
    private func enableNotifications() {
        if !notificationsEnabled && isAllowedToShowNotifications {
            UIApplication.shared.registerForRemoteNotifications()
        } else if !isAllowedToShowNotifications {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
                { (result, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
            }
        }
    }
    
}

struct NotificationSettings_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettings()
    }
}
