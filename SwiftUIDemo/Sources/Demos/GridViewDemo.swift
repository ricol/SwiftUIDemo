//
//  GridViewDemo.swift
//  SwiftUIDemo
//
//  Created by ricolwang on 2026/3/23.
//

import SwiftUI

struct AlignedGridView: View {
    var body: some View {
        ScrollView {
            Grid(alignment: .top, horizontalSpacing: 16, verticalSpacing: 20) {
                GridRow {
                    ProfileCard(name: "John Doe", role: "Developer")
                    ProfileCard(name: "Jane Smith", role: "Designer")
                }

                GridRow {
                    ProfileCard(name: "Bob Johnson", role: "Manager")
                    ProfileCard(name: "Alice Brown", role: "Product Owner")
                }

                GridRow {
                    // This will align to top of the row
                    Text("Note: All team members are remote")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .gridCellColumns(2)
                        .gridColumnAlignment(.center)
                }
            }
            .padding()
        }
    }
}

struct ProfileCard: View {
    let name: String
    let role: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(height: 80)

            Text(name)
                .font(.headline)
            Text(role)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    AlignedGridView()
}
