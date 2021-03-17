//
//  ValeoApp.swift
//  Valeo
//
//  Created by Lori Hill on 19.11.20.
//

import SwiftUI
import Firebase
import FirebaseMessaging
import GoogleMobileAds

/// The center of the App.
@main
struct ValeoApp: App {
        
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authentication = AuthenticationViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authentication.loggedIn {
                MainNavigationView()
                    .environmentObject(authentication)
                    .onAppear {
                        UIApplication.shared.applicationIconBadgeNumber = 0
                    }
            } else {
                LoginAndSignupView()
                    .environmentObject(authentication)
            }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Setting up Firebase
        FirebaseApp.configure()
        
        // Setting up Google AdMob
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // Setting up Cloud Messaging
        Messaging.messaging().delegate = self
        
        // Setting up notification
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // With swizzling disabled you must let Messaging know about the message, for Analytics
       Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)
    }
    
}


extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {

        let dataDict:[String: String] = ["token": fcmToken ]
        // Store token in Firestore for sending Notifications from Firebase
        let defaults = UserDefaults.standard
        let oldToken = defaults.string(forKey: "fcmToken")
        if oldToken != fcmToken {
            print("Setting new token")
            defaults.set(fcmToken, forKey: "fcmToken")
            defaults.setValue(true, forKey: "needToUploadFCMToken")
        }
        
        print(dataDict)
        
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    
    

    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    completionHandler([[.banner, .sound, .badge]])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    // Print message ID.
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }


    // Print full message.
    print(userInfo)

    completionHandler()
  }
}
