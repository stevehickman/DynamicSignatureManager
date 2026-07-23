//
//  DynamicSignaturePreferences.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


@MainActor
public final class DynamicSignaturePreferences:
    ObservableObject {


    @Published
    public var rotateAutomatically =
        true



    @Published
    public var launchAtLogin =
        false



    @Published
    public var copyAfterGeneration =
        true
}
