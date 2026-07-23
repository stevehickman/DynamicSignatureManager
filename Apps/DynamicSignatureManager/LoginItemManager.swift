//
//  LoginItemManager.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import ServiceManagement


public final class LoginItemManager {


    public init(){}



    public func enable()
    throws {


        try SMAppService
            .mainApp
            .register()
    }



    public func disable()
    throws {


        try SMAppService
            .mainApp
            .unregister()
    }
}
