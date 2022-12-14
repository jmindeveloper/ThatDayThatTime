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
    
    private func setTextInputAction() -> UNTextInputNotificationAction {
        UNTextInputNotificationAction(
            identifier: UNAction.textInput.identifier,
            title: "title",
            options: [],
            textInputButtonTitle: "작성",
            textInputPlaceholder: "기록"
        )
    }
    
    private func setDefaultCategory() {
        let category = UNNotificationCategory(
            identifier: UNCategory.defaultNoti.identifier,
            actions: [setTextInputAction()],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
        center.setNotificationCategories([category])
    }
    
    func addDefaultNotification() {
        var dateComponents = DateComponents()
        dateComponents = Calendar.current.dateComponents([.hour], from: Date())
        let subTitles = [
            "하루가 시작됐습니다",
            "벌써 하루의 반이 지났네요",
            "오늘 하루도 잘 보내셨나요?"
        ]
        let bodys = [
            "오늘의 계획이나 목표를 기록해보는건 어떨까요?",
            "오늘 점심식사는 어땠나요?",
            "오늘 하루 어떤일이 있었는지 기록해보세요!"
        ]
        
        
        defaultIdentifiers.enumerated().forEach { index, identifier in
            let content = UNMutableNotificationContent()
            content.title = "그날 그시간"
            content.subtitle = subTitles[index]
            content.body = bodys[index]
            content.sound = .default
            content.userInfo = [UNAction.textInput.identifier: ""]
            content.categoryIdentifier = UNCategory.defaultNoti.identifier
            
            setDefaultCategory()
            
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
    }
    
    func removeDefaultNotification() {
        center.removePendingNotificationRequests(withIdentifiers: defaultIdentifiers)
    }
}
