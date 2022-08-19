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
    var inputPassword = "" {
        didSet {
            if inputPassword.count == 4 {
                completeInputPassword.send(inputPassword)
            }
        }
    }
    private var createPassword = ""
    
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
}

// MARK: - Binidng
extension ApplicationPasswordViewModel {
    private func bindingSelf() {
        completeInputPassword
            .sink { [weak self] password in
                print("password: ", password)
                guard let self = self else { return }
                switch self.passwordEntryStatus {
                case .create:
                    self.doneInputPassword.send((.create, true))
                    self.passwordEntryStatus = .check
                    self.createPassword = self.inputPassword
                    self.inputPassword.removeAll()
                case .check:
                    self.doneInputPassword.send((.check, password == self.createPassword))
                case .run:
                    break
                }
            }.store(in: &subscriptions)
    }
}
