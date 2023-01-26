//
//  Event.swift
//  EventManager
//
//  Created by Ilya Kharlamov on 6/17/22.
//

import Foundation

public struct Event: Identifiable {

    public let id: Identifier
    public let name: String
    public var parameters: ParameterSet

    public init(id: Identifier, name: String, parameters: ParameterSet = [:]) {
        self.id = id
        self.name = name
        self.parameters = parameters
    }

}
