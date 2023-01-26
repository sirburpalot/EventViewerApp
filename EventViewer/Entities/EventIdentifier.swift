//
//  EventIdentifier.swift
//  EventsManager
//
//  Created by Ilya Kharlamov on 11/29/22.
//  Copyright © 2022 DIGITAL RETAIL TECHNOLOGIES, S.L. All rights reserved.
//

import Foundation

public extension Event {
    struct Identifier: Hashable, RawRepresentable {
        public let rawValue: String
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension Event.Identifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }
}

extension Event.Identifier: CustomStringConvertible {
    public var description: String { self.rawValue }
}
