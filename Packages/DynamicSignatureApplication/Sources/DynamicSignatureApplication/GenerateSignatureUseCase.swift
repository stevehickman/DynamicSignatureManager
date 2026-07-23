//
//  GenerateSignatureUseCase.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation
import DynamicSignatureDomain


public final class GenerateSignatureUseCase {


    private let profiles:
        ProfileRepository


    private let identities:
        IdentityRepository


    private let quotes:
        QuoteRepository


    private let history:
        SignatureHistoryRepository


    private var selector:
        QuoteSelectionEngine



    public init(

        profiles:
            ProfileRepository,

        identities:
            IdentityRepository,

        quotes:
            QuoteRepository,

        history:
            SignatureHistoryRepository,

        quoteEngine:
            QuoteSelectionEngine

    ) {

        self.profiles =
            profiles

        self.identities =
            identities

        self.quotes =
            quotes

        self.history =
            history

        self.selector =
            quoteEngine
    }



    public func execute(

        request:
            SignatureRequest

    ) throws -> Signature {


        guard let profile =
                try profiles.profile(
                    id:
                    request.profileID
                )

        else {

            throw ApplicationError
                .profileNotFound
        }



        guard let identity =
                try identities.identity(
                    id:
                    profile.identityID
                )

        else {

            throw ApplicationError
                .identityNotFound
        }



        let availableQuotes =
            try quotes.allQuotes()



        var quote:
            Quote?



        if profile.includeQuotes {


            quote =
                selector.nextQuote(
                    from:
                    availableQuotes
                )
        }



        let signature =
            SignatureComposer()
                .compose(

                    identity:
                        identity,

                    quote:
                        quote,

                    banners:
                        [],

                    template:
                        request.template
                )



        let entry =
            SignatureHistoryEntry(

                signatureID:
                    signature.id,

                quoteID:
                    quote?.id
            )



        try history.save(
            entry
        )


        return signature
    }
}
