//
//  ErrorHandler.swift
//  FamilyNovaParent
//
//  Centralized error handling utilities

import Foundation
import SwiftUI

class ErrorHandler {
    static let shared = ErrorHandler()
    
    private init() {}
    
    /// Convert an error to a user-friendly message
    func userFriendlyMessage(from error: Error) -> String {
        if let apiError = error as? ApiError {
            switch apiError {
            case .invalidURL:
                return "Invalid request. Please try again."
            case .invalidResponse:
                return "Unable to connect to server. Please check your internet connection."
            case .httpError(let code):
                switch code {
                case 401:
                    return "Your session has expired. Please log in again."
                case 403:
                    return "You don't have permission to perform this action."
                case 404:
                    return "The requested item was not found."
                case 429:
                    return "Too many requests. Please wait a moment and try again."
                case 500...599:
                    return "Server error. Please try again later."
                default:
                    return "Something went wrong. Please try again."
                }
            case .decodingError:
                return "Unable to process the response. Please try again."
            }
        }
        
        // Handle network errors
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return "No internet connection. Please check your network settings."
            case .timedOut:
                return "Request timed out. Please try again."
            case .cannotFindHost, .cannotConnectToHost:
                return "Unable to reach server. Please check your internet connection."
            default:
                return "Network error. Please try again."
            }
        }
        
        // Generic error
        return error.localizedDescription.isEmpty ? "An unexpected error occurred. Please try again." : error.localizedDescription
    }
    
    /// Show error toast
    func showError(_ error: Error, toast: Binding<ToastNotificationData?>) {
        let message = userFriendlyMessage(from: error)
        toast.wrappedValue = ToastNotificationData(
            title: "Error",
            message: message,
            icon: "exclamationmark.triangle.fill",
            color: .red
        )
        
        // Auto-dismiss after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            toast.wrappedValue = nil
        }
    }
    
    /// Show success toast
    func showSuccess(_ message: String, toast: Binding<ToastNotificationData?>) {
        toast.wrappedValue = ToastNotificationData(
            title: "Success",
            message: message,
            icon: "checkmark.circle.fill",
            color: .green
        )
        
        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toast.wrappedValue = nil
        }
    }
}

