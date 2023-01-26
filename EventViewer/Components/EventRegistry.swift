//
//  EventRegistry.swift
//  EventsManager
//
//  Created by Ilya Kharlamov on 11/29/22.
//  Copyright © 2022 DIGITAL RETAIL TECHNOLOGIES, S.L. All rights reserved.
//

import Foundation

public extension Event {

    static var signUp: Event {
        Event(id: .signUp, name: "Sign up")
    }

    static var login: Event {
        Event(id: .login, name: "Login")
    }

    static var logout: Event {
        Event(id: .logout, name: "Logout")
    }

    static func presentScene(_ scene: String) -> Event {
        var newParams: ParameterSet = [:]
        newParams[ParameterKey.scene] = .string(scene)
        return Event(id: .presentScene, name: "Present scene", parameters: newParams)
    }

}

public extension Event.Identifier {
    static let signUp: Event.Identifier = "sign_up"
    static let login: Event.Identifier = "login"
    static let logout: Event.Identifier = "logout"
    static let presentScene: Event.Identifier = "present_scene"
}

public extension Event {
    enum ParameterKey {
        public static let scene: ParameterSet.Key = "scene"
    }
}
