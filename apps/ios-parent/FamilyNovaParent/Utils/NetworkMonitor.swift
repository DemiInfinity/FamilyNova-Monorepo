//
//  NetworkMonitor.swift
//  FamilyNovaParent
//
//  Network connectivity monitoring

import Foundation
import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    @Published var connectionType: NWInterface.InterfaceType?
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

struct OfflineIndicator: View {
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        if !networkMonitor.isConnected {
            HStack(spacing: ParentAppSpacing.s) {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.white)
                Text("No Internet Connection")
                    .font(ParentAppFonts.caption)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, ParentAppSpacing.m)
            .padding(.vertical, ParentAppSpacing.s)
            .background(Color.red)
            .transition(.move(edge: .top))
        }
    }
}

