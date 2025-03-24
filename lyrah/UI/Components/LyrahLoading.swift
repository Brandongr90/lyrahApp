//
//  LyrahLoading.swift
//  lyrah
//
//  Created by Brandon Gonzalez on 24/03/25.
//

import SwiftUI

// Indicador de carga global para la app
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Cargando...")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 8)
            }
            .padding(25)
            .background(Color.primary.opacity(0.8))
            .cornerRadius(16)
        }
    }
}
