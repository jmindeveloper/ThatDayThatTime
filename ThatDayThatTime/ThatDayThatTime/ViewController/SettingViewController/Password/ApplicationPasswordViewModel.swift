//
//  ApplicationPasswordViewModel.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/19.
//

import Foundation
import Combine

final class ApplicationPasswordViewModel {
    
    enum PasswordEntryStatus {
        case run, create, check
    }
    
    private var passwordEntryStatus: PasswordEntryStatus
    private var subscriptions = Set<AnyCancellable>()
    private let completeInputPassword = PassthroughSubject<String, Never>()
    let doneInputPassword = PassthroughSubject<(status: PasswordEntryStatus, isValid: Bool), Never>()
    let showLocalAuth = PassthroughSubject<Void, Never>()
    var inputPassword = "" {
        didSet {
            if inputPassword.count == 4 {
                completeInputPassword.send(inputPassword)
            }
        }
    }
    private var createPassword = ""
    private let password = UserSettingManager.shared.getPassword()
    
    init(passwordEntryStatus: PasswordEntryStatus) {
        self.passwordEntryStatus = passwordEntryStatus
        bindingSelf()
    }
}

// MARK: - Method
extension ApplicationPasswordViewModel {
    func appendPassword(num: String) {
        inputPassword.append(num)
    }
    
    func deletePassword() {
        if !inputPassword.isEmpty {
            inputPassword.removeLast()
        }
    }
    
    func localAuth() {
        if passwordEntryStatus == .run && UserSettingManager.shared.getLocalAuth() {
            showLocalAuth.send()
        }
    }
}

// MARK: - Binidng
extension ApplicationPasswordViewModel {
    private func bindingSelf() {
        completeInputPassword
            .sink { [weak self] password in
                guard let self = self else { return }
                switch self.passwordEntryStatus {
                case .create:
                    self.doneInputPassword.send((.create, true))
                    self.passwordEntryStatus = .check
                    self.createPassword = self.inputPassword
                    self.inputPassword.removeAll()
                case .check:
                    let isValid = password == self.createPassword
                    if !isValid {
                        self.inputPassword.removeAll()
                    } else {
                        UserSettingManager.shared.setSecurityState(securityState: true)
                        UserSettingManager.shared.setPassword(password: password)
                    }
                    self.doneInputPassword.send((.check, isValid))
                case .run:
                    let isValid = self.password == password
                    if !isValid {
                        self.inputPassword.removeAll()
                    }
                    self.doneInputPassword.send((.run, isValid))
                }
            }.store(in: &subscriptions)
    }
}
