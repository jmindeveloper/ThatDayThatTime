//
//  LocalAuth.swift
//  ThatDayThatTime
//
//  Created by J_Min on 2022/08/20.
//

import Foundation
import LocalAuthentication

struct LocalAuth {
    static func localAuth(successAuth: @escaping (() -> Void), noAuthority: (() -> Void)) {
        
        let authContext = LAContext()
        var description = ""
        
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            switch authContext.biometryType {
            case .faceID:
                description = "로그인을 위해 faceID를 인증해주세요"
            case .touchID:
                description = "로그인을 위해 touchID를 인증해주세요"
            default:
                break
            }
            
            authContext.localizedFallbackTitle = ""
            authContext.localizedCancelTitle = "비밀번호 입력"
            
            authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: description) { success, error in
                if success {
                    DispatchQueue.main.async {
                        successAuth()
                    }
                } else {
                    if let error = error {
                        print(error._code)
                    }
                }
            }
        } else {
            noAuthority()
        }
    }
}
