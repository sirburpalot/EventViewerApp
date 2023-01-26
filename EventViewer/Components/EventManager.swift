//
//  EventManager.swift
//  Core
//
//  Created by Ilya Kharlamov on 21.05.2021.
//  Copyright © 2021 DIGITAL RETAIL TECHNOLOGIES, S.L. All rights reserved.
//

import Foundation

public protocol EventManager: AnyObject {
    var queue: DispatchQueue { get }
    func capture(_ event: Event)
}
