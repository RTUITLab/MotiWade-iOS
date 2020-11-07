//
//  WebPage.swift
//  MotiWade
//
//  Created by Mikhail Ivanov on 07.11.2020.
//

import SwiftUI

struct WebPage: View {
    @State var url: String
    var body: some View {
        WebView(url: url)
            .edgesIgnoringSafeArea(.all)
    }
}

struct WebPage_Previews: PreviewProvider {
    static var previews: some View {
        WebPage(url: "")
    }
}
