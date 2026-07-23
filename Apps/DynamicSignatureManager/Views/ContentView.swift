//
//  ContentView.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import SwiftUI


struct ContentView:
    View {


    @StateObject
    private var model =
        SignatureViewModel()



    var body:
        some View {


        VStack(
            spacing:
                20
        ) {


            SignaturePreviewView(
                text:
                    model.signatureText
            )


            Button(
                "Copy Signature"
            ) {

                ClipboardService()
                    .copy(
                        model.signatureText
                    )
            }
        }
        .padding()
    }
}
