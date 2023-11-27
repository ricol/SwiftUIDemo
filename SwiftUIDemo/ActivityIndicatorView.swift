//
//  ActivityIndicatorView.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/15.
//

import SwiftUI

struct ActivityIndicatorView: UIViewRepresentable {
    var isShowing: Bool
    var color: UIColor

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let a = UIActivityIndicatorView()
        a.color = color
        return a
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        isShowing ? uiView.startAnimating() : uiView.stopAnimating()
    }
    
    typealias UIViewType = UIActivityIndicatorView
}

#Preview {
    ActivityIndicatorView(isShowing: true, color: .red)
}
