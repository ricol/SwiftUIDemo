//
//  extensions.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2026/1/20.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let h = hex.filter({ ["a", "b", "c", "d", "e", "f", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains($0) })
        let scanner = Scanner(string: h)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff
        )
    }
}
