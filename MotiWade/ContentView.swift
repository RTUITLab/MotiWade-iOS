//
//  ContentView.swift
//  MotiWade
//
//  Created by Mikhail Ivanov on 06.11.2020.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

class WebLoading: ObservableObject {
    @Published var isLoaded: Bool = false
    @Published var isOpacity: Bool = true
    @Published var isUpdate = false
    @Published var isWeb: Bool = false
}

struct ContentView: View {
    @State var offset: CGFloat = 0
    
    @State var url: String = ""
    @ObservedObject var webLoading = WebLoading()
    
    @State var colors: [Color] = [Color(hex: "a200d7"), Color(hex: "00ffce")]
    @State var hueRotationValue = 0.0
    @State var saturationValue = 1.0
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: colors), startPoint: .bottom, endPoint: .top)
                .hueRotation(Angle(degrees: self.hueRotationValue))
                .saturation(self.saturationValue)
            
            GeometryReader { g in
                VStack {
                    Image("clipped")
                        .frame(height: g.size.height / 4)
                        .offset(x: -500 - (300 + self.offset))
                    Spacer()
                    Image("clipped")
                        .frame(height: g.size.height / 4)
                        .offset(x: self.offset)
                }
                .onAppear {
                    withAnimation(Animation.linear(duration: 15).repeatForever()) { self.offset = -800 }
                }
                
            }
            
            if  !webLoading.isOpacity && !webLoading.isLoaded {
                ProgressView()
            }
            
            if webLoading.isWeb {
                VStack{
                    
                    GeometryReader { g in
                        WebView(url: url).frame(width: g.size.width, height: webLoading.isLoaded ? g.size.height : 0.01).environmentObject(webLoading)
                        
                    }
                }
                
            }
            
            ZStack {
                VStack {
                    Image("LogoProject")
                    Text("Motivates you to care")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                }
                
                GeometryReader { g in
                    VStack {
                        Button(action: {
                            url = "/onboarding"
                            
                            
                            withAnimation (Animation.easeInOut(duration: 2)){
                                //                                self.saturationValue = 0.7
                                webLoading.isOpacity.toggle()
                            }
                            
                            
                            withAnimation (Animation.easeInOut(duration: 3)){
                                self.hueRotationValue = 150
                                webLoading.isWeb = true
                            }
                            
                        }){
                            Text("Start journey")
                                .fontWeight(.bold)
                                .padding(.horizontal, 40.0)
                                .padding(.vertical, 10.0)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .font(.title3)
                        }.padding(.bottom, 10)
                        
                        Button(action: {
                            url = "/test/page/1"
                            
                            withAnimation (Animation.easeInOut(duration: 2)){
                                //                                self.saturationValue = 0.7
                                webLoading.isOpacity.toggle()
                            }
                            
                            
                            withAnimation (Animation.easeInOut(duration: 3)){
                                self.hueRotationValue = -150
                                webLoading.isWeb = true
                            }
                        }){
                            Text("Skip onboarding")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .opacity(0.6)
                                .font(.title3)
                        }
                    }
                    .padding(.bottom, 30)
                    .frame(width: g.size.width, height: g.size.height, alignment: .bottom)
                    
                }
            }
            .opacity(webLoading.isOpacity ? 1 : 0)
            .transition(.opacity)
            
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
