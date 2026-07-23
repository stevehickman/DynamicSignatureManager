//
//  ContentView.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import SwiftUI


struct ContentView:
    View {


    var body:
        some View {


        NavigationStack {


            VStack(spacing: 20) {


                Text(
                    "Dynamic Signature Manager"
                )
                .font(
                    .largeTitle
                )


                Text(
                    "Ready"
                )
            }
            .padding()
        }
    }
}
