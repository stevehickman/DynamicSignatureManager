//
//  QuoteLibraryView.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import SwiftUI


struct QuoteLibraryView:
    View {


    @State private var search = ""



    var body:
        some View {


        VStack {


            TextField(
                "Search quotes",
                text:
                    $search
            )


            List {


                Text(
                    "Quote Library"
                )

            }
        }
        .padding()
    }
}
