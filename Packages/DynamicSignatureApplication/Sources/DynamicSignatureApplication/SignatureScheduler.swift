//
//  SignatureScheduler.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public actor SignatureScheduler {


    private var task:
        Task<Void, Never>?



    public init(){}



    public func start(
        interval:
            TimeInterval = 3600,

        action:
            @escaping () async -> Void
    ) {


        task =
            Task {


                while !Task.isCancelled {


                    await action()


                    try? await Task
                        .sleep(
                            nanoseconds:
                                UInt64(
                                    interval *
                                    1_000_000_000
                                )
                        )
                }
            }
    }



    public func stop() {

        task?.cancel()

        task = nil
    }
}
