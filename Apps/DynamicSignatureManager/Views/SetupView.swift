//
//  SetupView.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import SwiftUI
import DynamicSignatureDomain


struct SetupView:
    View {


    @State private var name = ""



    var body:
        some View {


        Form {


            Text(
                "Welcome"
            )
            .font(
                .title
            )


            TextField(
                "Your name",
                text:
                    $name
            )


            Button(
                "Create Identity"
            ) {

                // save identity
            }
        }
        .padding()
    }
}
