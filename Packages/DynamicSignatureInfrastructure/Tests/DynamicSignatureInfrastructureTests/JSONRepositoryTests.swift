//
//  JSONRepositoryTests.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Testing
import Foundation
@testable import DynamicSignatureInfrastructure


@Test
func repositoryRoundTrip()
throws {


    struct TestObject:
        Codable,
        Identifiable {

        let id = UUID()

        let name: String
    }


    let url =
        FileManager.default
        .temporaryDirectory
        .appending(
            path:
            "test.json"
        )


    let repository =
        JSONRepository<TestObject>(
            fileURL:
                url
        )


    let object =
        TestObject(
            name:
            "Test"
        )


    try repository.save(
        [object]
    )


    let loaded =
        try repository.load()


    #expect(
        loaded.count == 1
    )

    #expect(
        loaded.first?.name == "Test"
    )
}
