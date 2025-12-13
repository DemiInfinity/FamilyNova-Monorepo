//
//  QRCodeGenerator.swift
//  FamilyNovaParent
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

class QRCodeGenerator {
    static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        
        guard let qrCodeImage = filter.outputImage else {
            return nil
        }
        
        // Scale up the image for better quality
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = qrCodeImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

struct QRCodeView: View {
    let qrCodeString: String
    @State private var qrImage: UIImage?
    
    var body: some View {
        VStack(spacing: ParentAppSpacing.m) {
            if let image = qrImage {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(ParentAppCornerRadius.medium)
            } else {
                ProgressView()
                    .frame(width: 250, height: 250)
            }
            
            Text("Scan this QR code with the Nova app to log in")
                .font(ParentAppFonts.caption)
                .foregroundColor(ParentAppColors.darkGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ParentAppSpacing.m)
        }
        .onAppear {
            qrImage = QRCodeGenerator.generateQRCode(from: qrCodeString)
        }
    }
}

