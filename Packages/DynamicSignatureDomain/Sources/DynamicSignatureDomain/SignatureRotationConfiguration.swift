//
//  SignatureRotationConfiguration.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public struct SignatureRotationConfiguration:
    Codable,
    Hashable {


    public var enabled: Bool

    public var interval:
        RotationInterval


    public var avoidRepeats:
        Int



    public init(
        enabled: Bool = true,
        interval:
            RotationInterval = .daily,
        avoidRepeats:
            Int = 10
    ) {

        self.enabled = enabled
        self.interval = interval
        self.avoidRepeats = avoidRepeats
    }
}
