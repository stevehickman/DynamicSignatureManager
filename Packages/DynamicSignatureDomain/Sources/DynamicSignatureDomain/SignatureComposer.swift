//
//  SignatureComposer.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import Foundation


public struct SignatureComposer {


    public init() {}


    public func compose(
        identity: Identity,
        quote: Quote?,
        banners: [Banner],
        template: SignatureTemplate
    ) -> Signature {


        var components: [String] = []


        if template.includeIdentity {

            components.append(
                identity.displayName
            )


            if let title =
                identity.title {

                components.append(title)
            }


            if let org =
                identity.organization {

                components.append(org)
            }
        }


        if template.includeBanner {

            banners
                .filter(\.isEnabled)
                .sorted {
                    $0.priority > $1.priority
                }
                .forEach {

                    components.append(
                        $0.text
                    )
                }
        }


        if template.includeQuote,
           let quote {


            var text =
                "\"\(quote.text)\""


            if let author =
                quote.author {

                text += "\n— \(author)"
            }


            components.append(text)
        }


        return Signature(
            identityID: identity.id,
            quoteID: quote?.id,
            bannerIDs: banners.map(\.id),
            body: components.joined(
                separator: "\n\n"
            )
        )
    }
}
