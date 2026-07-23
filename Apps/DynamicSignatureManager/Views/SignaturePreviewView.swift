//
//  SignaturePreviewView.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import SwiftUI


struct SignaturePreviewView:
    View {


    let text:
        String



    var body:
        some View {


        ScrollView {


            Text(text)
                .frame(
                    maxWidth:
                        .infinity,
                    alignment:
                        .leading
                )
                .padding()
        }
        .border(
            .gray
        )
    }
}
