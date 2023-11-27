//
//  ClockDemo.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/22.
//

import SwiftUI

struct Dash: Shape {
    var target: CGPoint
    var angle: CGFloat
    var len: CGFloat = 10
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: start)
        p.addLine(to: target)
        return p
    }
    
    private var start: CGPoint {
        return CGPoint(x: target.x - len * cos(angle), y: target.y - len * sin(angle))
    }
}

struct Pen: Shape {
    var start: CGPoint
    var end: CGPoint
    var lineWidth: CGFloat = 1.0
    var innerRadius: CGFloat = 5
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: start)
        p.addLine(to: end)
        p.addArc(center: end, radius: innerRadius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 360), clockwise: true)
        return p
    }
}

let _pi: CGFloat = 3.1415216

struct ClockDemo: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue, .green], startPoint: .top, endPoint: .bottom)
            ZStack {
                Clock(center: CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2),
                      radius: 180, innerRadius: 20.0)
                Clock(center:  CGPoint(x: UIScreen.main.bounds.size.width / 2 + 60, y: UIScreen.main.bounds.size.height / 2 + 50), radius: 40, innerRadius: 10.0, bigClock: false)
            }
        }.ignoresSafeArea()
    }
}

struct Clock: View {
    var timezone: TimeZone = TimeZone.current
    var start: Date = Date()
    var center = CGPoint(x: 0, y: 0)
    var radius: CGFloat = 0.0
    var innerRadius: CGFloat = 20.0
    var bigClock = true
    var digital = true
    var hourColor: Color = .white
    var minuteColor: Color = .white
    var secondColor: Color = .white
    var indicatorColor: Color = .yellow
    var numberColor: Color = .white
    var frameColor: Color = .white
    let _delta: CGFloat = -_pi / 2.0
    
    var body: some View {
        ZStack {
            ClockFrameView(bigClock: bigClock, 
                           radius: radius,
                           center: center,
                           _delta: _delta,
                           indicatorColor: indicatorColor,
                           numberColor: numberColor)
            ClockContentView(timezone: timezone, 
                             start: start,
                             bigClock: bigClock,
                             digital: digital,
                             radius: radius,
                             center: center,
                             _delta: _delta,
                             innerRadius: innerRadius,
                             hourColor: hourColor,
                             minuteColor: minuteColor,
                             secondColor: secondColor,
                             numberColor: numberColor)
            
        }.foregroundColor(frameColor)
    }
}

#Preview {
    ClockDemo()
}

struct ClockFrameView: View {
    var bigClock = true
    var radius: CGFloat
    var center: CGPoint
    var _delta: CGFloat
    var indicatorColor: Color
    var numberColor: Color
    
    var body: some View {
        Circle().stroke(lineWidth: bigClock ? 5 : 2).frame(width: radius * 2, height: radius * 2).padding().position(center)
        if bigClock {
            ForEach(0...59, id: \.self) { n in
                Dash(target: ClockContentView.getPoint(radius: radius, value: CGFloat(n), totalValue: 60, factor: 0.98, delta: 0, relativeValue: center), angle: CGFloat(n) / 60.0 * 2 * _pi, len: n == 0 || n == 15 || n == 30 || n == 45 ? 20 : 10).stroke(lineWidth: n % 5 == 0 ? 10 : 3).foregroundStyle(indicatorColor)
            }
            ForEach(1...12, id: \.self) { n in
                Text("\(n)").font(.title).position(ClockContentView.getPoint(radius: radius, value: CGFloat(n), totalValue: 12, factor: 0.8, delta: _delta, relativeValue: center)).foregroundColor(numberColor)
            }
        }else {
            ForEach(0...59, id: \.self) { n in
                Dash(target: ClockContentView.getPoint(radius: radius, value: CGFloat(n), totalValue: 60, factor: 1, delta: 0, relativeValue: center), angle: CGFloat(n) / 60.0 * 2 * _pi, len: n == 0 || n == 15 || n == 30 || n == 45 ? 10 : 5).stroke(lineWidth: n == 0 || n == 15 || n == 30 || n == 45 ? 5 : 2).foregroundStyle(indicatorColor)
            }
        }
    }
}

struct ClockContentView: View {
    var timezone: TimeZone
    var start: Date
    var bigClock: Bool
    var digital: Bool
    var radius: CGFloat
    var center: CGPoint
    var _delta: CGFloat
    var innerRadius: CGFloat
    var hourColor: Color
    var minuteColor: Color
    var secondColor: Color
    var numberColor: Color
    
    @State var hour: CGFloat = 0
    @State var minute: CGFloat = 0
    @State var second: CGFloat = 0
    @State var ssecondTotal: CGFloat = 0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    var body: some View {
        if bigClock {
            Pen(start: center, end: ClockContentView.getPoint(radius: radius, value: hour, totalValue: 12, factor: 0.6, delta: _delta, relativeValue: center)).stroke(lineWidth: 5).foregroundStyle(hourColor)
            Pen(start: center, end: ClockContentView.getPoint(radius: radius, value: minute, totalValue: 60, factor: 0.7, delta: _delta, relativeValue: center)).stroke(lineWidth: 5).foregroundStyle(minuteColor)
            Pen(start: center, end: ClockContentView.getPoint(radius: radius, value: second, totalValue: 60, factor: 0.8, delta: _delta, relativeValue: center)).stroke(lineWidth: 5).foregroundStyle(secondColor)
        }else {
            Pen(start: center, end: ClockContentView.getPoint(radius: radius, value: ssecondTotal, totalValue: 600, factor: 0.6, delta: _delta, relativeValue: center), innerRadius: 2).stroke(lineWidth: 5).foregroundStyle(.white)
        }
        
        Circle().frame(width: innerRadius, height: innerRadius).position(center).onReceive(timer, perform: { _ in
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = timezone
            let date = start.addingTimeInterval(Date().timeIntervalSince(start)) // save date, so all components use the same date
            hour = CGFloat(calendar.component(.hour, from: date))
            minute = CGFloat(calendar.component(.minute, from: date))
            second = CGFloat(calendar.component(.second, from: date))
            if (second == 0) { ssecondTotal = 0 }
            ssecondTotal += 1
        })
        if digital {
            Text("\(Int(hour)):\(Int(minute)):\(Int(second)).\(Int(ssecondTotal))").padding(.top, 500).font(.title).foregroundColor(numberColor)
        }
    }
    
    static func getPoint(radius: CGFloat, value: CGFloat, totalValue: CGFloat, factor: CGFloat, delta: CGFloat, relativeValue: CGPoint) -> CGPoint {
        CGPoint(x: radius * factor * cos(value / totalValue * (2 * _pi) + delta) + relativeValue.x,
                y: radius * factor * sin(value / totalValue * (2 * _pi) + delta) + relativeValue.y)
    }
}
