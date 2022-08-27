//
//  UserNotificationManager.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/21.
//

import Foundation
import UserNotifications

final class UserNotificationManager: NSObject {
    
    private let center = UNUserNotificationCenter.current()
    private let defaultIdentifiers = ["morning", "afternoon", "evening"]
    
    override init() {
        super.init()
        center.delegate = self
    }
    
    static func authorization(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        
        let authrizationOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .sound])
        
        center.requestAuthorization(options: authrizationOptions) { successe, error in
            DispatchQueue.main.async {
                completion(successe)
            }
        }
    }
    
    func addDefaultNotification() {
        var dateComponents = DateComponents()
        dateComponents = Calendar.current.dateComponents([.hour], from: Date())
        
        defaultIdentifiers.enumerated().forEach { index, identifier in
            let content = UNMutableNotificationContent()
            content.title = "그날 그시간"
            content.sound = .default
            
            switch index {
            case 0:
                dateComponents.hour = 9
            case 1:
                dateComponents.hour = 13
            case 2:
                dateComponents.hour = 20
            default: break
            }
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getPendingNotificationRequests { notis in
            print(notis.count)
        }
    }
    
    func removeDefaultNotification() {
        center.removePendingNotificationRequests(withIdentifiers: defaultIdentifiers)
        center.getPendingNotificationRequests { notis in
            print(notis.count)
        }
    }
}

extension UserNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
