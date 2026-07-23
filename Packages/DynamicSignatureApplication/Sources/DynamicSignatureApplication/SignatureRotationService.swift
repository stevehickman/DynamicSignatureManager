//
//  SignatureRotationService.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public final class SignatureRotationService {


    private let selector:
        AdaptiveQuoteSelector



    public init() {

        selector =
            AdaptiveQuoteSelector()
    }



    public func shouldRotate(
        lastGenerated:
            Date?,
        configuration:
            SignatureRotationConfiguration
    )
    -> Bool {


        guard configuration.enabled
        else {

            return false
        }


        guard let lastGenerated
        else {

            return true
        }



        switch configuration.interval {


        case .everyMessage:

            return true


        case .hourly:

            return Date.now
                .timeIntervalSince(
                    lastGenerated
                )
                >
                3600


        case .daily:

            return !Calendar.current
                .isDateInToday(
                    lastGenerated
                )


        case .weekly:

            return Date.now
                .timeIntervalSince(
                    lastGenerated
                )
                >
                604800
        }
    }
}
