//
//  ConnectionsView.swift
//  FamilyNovaParent
//

import SwiftUI

struct ConnectionsView: View {
    @State private var connections: [ParentConnection] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if connections.isEmpty {
                    VStack(spacing: ParentAppSpacing.m) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 48))
                            .foregroundColor(ParentAppColors.mediumGray)
                        Text("No parent connections yet")
                            .font(ParentAppFonts.body)
                            .foregroundColor(ParentAppColors.darkGray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: ParentAppSpacing.m) {
                            ForEach(connections) { connection in
                                ConnectionCard(connection: connection)
                            }
                        }
                        .padding(ParentAppSpacing.m)
                    }
                }
            }
            .background(ParentAppColors.lightGray)
            .navigationTitle("Parent Connections")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ConnectionCard: View {
    let connection: ParentConnection
    
    var body: some View {
        HStack(spacing: ParentAppSpacing.m) {
            // Avatar
            Circle()
                .fill(ParentAppColors.primaryTeal)
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                )
            
            // Connection Info
            VStack(alignment: .leading, spacing: ParentAppSpacing.xs) {
                Text(connection.parent.displayName)
                    .font(ParentAppFonts.headline)
                    .foregroundColor(ParentAppColors.black)
                
                Text("Connected: \(connection.connectedAt, style: .relative)")
                    .font(ParentAppFonts.small)
                    .foregroundColor(ParentAppColors.darkGray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Message")
                    .font(ParentAppFonts.small)
                    .foregroundColor(.white)
                    .padding(.horizontal, ParentAppSpacing.m)
                    .padding(.vertical, ParentAppSpacing.s)
                    .background(ParentAppColors.primaryTeal)
                    .cornerRadius(ParentAppCornerRadius.small)
            }
        }
        .padding(ParentAppSpacing.m)
        .background(Color.white)
        .cornerRadius(ParentAppCornerRadius.medium)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ConnectionsView()
}

