//
//  RotationInterval.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

public enum RotationInterval:
    String,
    Codable {


    case everyMessage

    case hourly

    case daily

    case weekly
}
