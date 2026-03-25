//
//  LoadingSpinnerView.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2026/3/12.
//

import SwiftUI

struct LoadingSpinnerView: View {
    @State private var isCircleRotating = true
    @State private var animateStart = false
    @State private var animateEnd = true
    @State private var bgOpacity = 0.0
    var radius: CGFloat = 40
    var bgColor: Color = .gray
    var fgColor: Color = .white
    var coverColor: Color = .gray

    var body: some View {
        ZStack {
            coverColor.opacity(bgOpacity).ignoresSafeArea()
            Circle()
                .stroke(lineWidth: 3)
                .fill(bgColor)
                .frame(width: radius, height: radius)
            Circle()
                .trim(from: animateStart ? 1/3 : 1/9, to: animateEnd ? 2/5 : 1)
                .stroke(lineWidth: 3)
                .rotationEffect(.degrees(isCircleRotating ? -360 : 0))
                .frame(width: radius, height: radius)
                .foregroundColor(fgColor)
                .onAppear {
                    withAnimation(Animation
                                    .linear(duration: 1)
                                    .repeatForever(autoreverses: false)) {
                        self.isCircleRotating.toggle()
                    }
                    withAnimation(Animation
                                    .linear(duration: 1)
                                    .delay(0.5)
                                    .repeatForever(autoreverses: true)) {
                        self.animateStart.toggle()
                    }
                    withAnimation(Animation
                                    .linear(duration: 1)
                                    .delay(1)
                                    .repeatForever(autoreverses: true)) {
                        self.animateEnd.toggle()
                    }
                    withAnimation {
                        bgOpacity = 0.3
                    }
                }
        }
    }
}

struct LoadingSpinnerViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    func body(content: Content) -> some View {
        content.overlay {
            if isPresented {
                LoadingSpinnerView()
            }
        }
    }
}

extension View {
    func loadingSpinner(isPresented: Binding<Bool>) -> some View {
        self.modifier(LoadingSpinnerViewModifier(isPresented: isPresented))
    }
}

struct LoadingSpinnerViewPreview: View {
    @State private var showLoadingSpinner = false

    var body: some View {
        NavigationStack {
            VStack {
            }
            .navigationTitle("Loading Spinner Demo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Show") {
                        showLoadingSpinner = true
                        Task {
                            try await Task.sleep(nanoseconds: UInt64(1e9) * 2)
                            showLoadingSpinner = false
                        }
                    }
                }
            }
        }.loadingSpinner(isPresented: $showLoadingSpinner)
    }
}

#Preview {
    LoadingSpinnerView(radius: 40)
}

#Preview {
    LoadingSpinnerViewPreview()
}
