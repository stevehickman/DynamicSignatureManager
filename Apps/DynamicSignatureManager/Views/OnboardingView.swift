//
//  OnboardingView.swift
//  
//
//  Created by Steve Hickman on 7/23/26.
//

import SwiftUI


struct OnboardingView:
    View {


    @State
    private var page = 0



    var body:
        some View {


        TabView(
            selection:
                $page
        ) {


            Text(
                "Welcome"
            )
            .tag(0)



            Text(
                "Create your first signature"
            )
            .tag(1)



            Text(
                "Ready"
            )
            .tag(2)
        }
        .tabViewStyle(
            .page
        )
    }
}
