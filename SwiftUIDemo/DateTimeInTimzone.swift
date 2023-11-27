//
//  DateTimeInTimzone.swift
//  SwiftUIDemo
//
//  Created by Ricol Wang on 2023/11/27.
//

import SwiftUI

class TimeZonesViewModel: ObservableObject {
    @Published var timezones: [String] = ["Asia/Shanghai", "America/New_York", "America/Denver"]
    @Published var selectedTimezone: String = "Asia/Shanghai"
    @Published var date: Date = Date()
    
    var allTimezones: [String] {
        TimeZone.knownTimeZoneIdentifiers
    }
    
    private var _continentsMapping: [String: [String]]?
    var continentsMapping: [String: [String]] {
        if let _continentsMapping { return _continentsMapping }
        var r = [String: [String]]()
        allTimezones.forEach { e in
            let data = e.split(separator: "/")
            if let first = data.first, let second = data.last {
                let continent = String(first)
                let city = String(second)
                if r[continent] == nil { r[continent] = [String]() }
                r[continent]?.append(city)
            }
        }
        _continentsMapping = r
        return r
    }
    var allContinents: [String] {
        var r = [String]()
        continentsMapping.keys.forEach { k in
            r.append(k)
        }
        return r.sorted()
    }
}

struct DateTimeInTimzone: View {
    @StateObject var vm = TimeZonesViewModel()
    var body: some View {
        NavigationView {
            Form {
                Section("Current Timezone")
                {
                    HStack {
                        Picker("Select timezone: ", selection: $vm.selectedTimezone) {
                            ForEach(vm.timezones, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    Button("Use current time") {
                        vm.date = Date()
                    }
                    DatePicker("DateTime: ", selection: $vm.date, displayedComponents: [.date, .hourAndMinute])
                }
                Section("Time in Other Timezones: ") {
                    DisplayInOtherTimeZones(vm: vm)
                }
                Section("Manage Timezones") {
                    NavigationLink {
                        MyFavouriteTimeZonesView(vm: vm)
                    } label: {
                        Text("My Favourite Timezones")
                    }
                }
            }.padding(10).navigationTitle("TimeZone").onAppear() {
                vm.date = Date()
            }.navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DisplayInOtherTimeZones: View {
    @ObservedObject var vm: TimeZonesViewModel
    let clockSize: CGFloat = 70
    var body: some View {
        ScrollView(.vertical) {
            ForEach(vm.timezones, id: \.self) { timezone in
                HStack(alignment: .center) {
                    VStack(alignment:.leading, spacing: 10) {
                        HStack {
                            Text(timezone)
                            if timezone == vm.selectedTimezone {
                                Image(systemName: "checkmark.circle")
                            }
                        }
                        Text(getResultFor(date: vm.date, fromTimezone: vm.selectedTimezone, toTimezone: timezone))
                    }
                    Spacer()
                    Clock(timezone: TimeZone(identifier: timezone)!, start: toDateIn(timezome: timezone, date: Date())!,
                          center: CGPoint(x: 30, y: 30),
                          radius: 180,
                          innerRadius: 20.0,
                          digital: false,
                          hourColor: .black,
                          minuteColor: .black,
                          secondColor: .black,
                          indicatorColor: .black,
                          numberColor: .black,
                          frameColor: .black).frame(width: clockSize, height: clockSize)
                    .scaleEffect(CGSize(width: 0.22, height: 0.22))
                }.frame(height: 100).padding(.top, 10).padding(.bottom, 10).padding(.trailing, 10)
            }
        }
    }
    
    private func getResultFor(date: Date, fromTimezone: String, toTimezone: String) -> String {
        guard let fromTimezone = TimeZone(identifier: fromTimezone) else { return "" }
        
        var components = DateComponents()
        components.timeZone = fromTimezone
        let c = Calendar.current.dateComponents([.day, .year, .month, .hour, .minute, .second], from: date)
        components.year = c.year
        components.month = c.month
        components.day = c.day
        components.hour = c.hour
        components.minute = c.minute
        components.second = c.second
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = fromTimezone
        guard let targetDate = calendar.date(from: components) else { return "" }
        let df = DateFormatter()
        df.dateFormat = "yy/MM/dd H:mm:s"
        if toTimezone == "GMT/GMT" {
            df.timeZone = TimeZone.gmt
            return df.string(from: targetDate)
        }else if let denverTimeZone = TimeZone(identifier: toTimezone) {
            df.timeZone = denverTimeZone
            return df.string(from: targetDate)
        }
        return ""
    }
    
    private func toDateIn(timezome: String, date: Date) -> Date? {
        guard let toTimezone = TimeZone(identifier: timezome) else { return nil }
        
        var components = DateComponents()
        components.timeZone = toTimezone
        let c = Calendar.current.dateComponents([.day, .year, .month, .hour, .minute, .second], from: date)
        components.year = c.year
        components.month = c.month
        components.day = c.day
        components.hour = c.hour
        components.minute = c.minute
        components.second = c.second
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = toTimezone
        return calendar.date(from: components)
    }
}

struct MyFavouriteTimeZonesView: View {
    @ObservedObject var vm: TimeZonesViewModel
    var body: some View {
        Form {
            ForEach(vm.allContinents, id: \.self) { continent in
                NavigationLink {
                    CitiesView(vm: vm, continent: continent)
                } label: {
                    Text(continent)
                }
            }
        }.navigationTitle("All Continents").navigationBarTitleDisplayMode(.inline)
    }
}

struct CitiesView: View {
    @ObservedObject var vm: TimeZonesViewModel
    var continent: String
    var cities: [String] {
        vm.continentsMapping[continent] ?? []
    }
    var body: some View {
        Form {
            ForEach(cities, id: \.self) { city in
                Button {
                    if vm.timezones.contains("\(continent)/\(city)") {
                        vm.timezones.removeAll { e in
                            e == "\(continent)/\(city)"
                        }
                    }else {
                        vm.timezones.append("\(continent)/\(city)")
                        vm.timezones = vm.timezones.sorted { a, b in
                            a < b
                        }
                    }
                } label: {
                    HStack {
                        Text(city)
                        Spacer()
                        if vm.timezones.contains("\(continent)/\(city)") {
                            Image(systemName: "checkmark.circle")
                        }
                    }
                }.foregroundColor(.black)
            }
        }.navigationTitle(continent)
    }
}

#Preview {
    DateTimeInTimzone()
}
