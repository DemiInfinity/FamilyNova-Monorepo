//
//  Encryption.swift
//  FamilyNovaKids
//

import Foundation
import CommonCrypto

class Encryption {
    // Encryption key - should match backend key
    private static let encryptionKey: String = {
        if let key = ProcessInfo.processInfo.environment["ENCRYPTION_KEY"] {
            return key
        }
        return "your-32-byte-encryption-key-here-must-match-backend"
    }()
    
    private static let algorithm = kCCAlgorithmAES
    private static let keySize = kCCKeySizeAES256
    private static let ivSize = kCCBlockSizeAES128
    private static let options = CCOptions(kCCOptionPKCS7Padding)
    
    static func encrypt(_ plainText: String) throws -> String {
        guard let data = plainText.data(using: .utf8) else {
            throw EncryptionError.invalidInput
        }
        
        let key = prepareKey(encryptionKey)
        var iv = [UInt8](repeating: 0, count: ivSize)
        let status = SecRandomCopyBytes(kSecRandomDefault, ivSize, &iv)
        guard status == errSecSuccess else {
            throw EncryptionError.keyGenerationFailed
        }
        
        var encryptedData = [UInt8](repeating: 0, count: data.count + ivSize)
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = CCCrypt(
            CCOperation(kCCEncrypt),
            algorithm,
            options,
            key,
            keySize,
            iv,
            Array(data),
            data.count,
            &encryptedData,
            encryptedData.count,
            &numBytesEncrypted
        )
        
        guard cryptStatus == kCCSuccess else {
            throw EncryptionError.encryptionFailed
        }
        
        let combined = iv + Array(encryptedData.prefix(Int(numBytesEncrypted)))
        let combinedData = Data(combined)
        
        let ivBase64 = Data(iv).base64EncodedString()
        let encryptedBase64 = combinedData.base64EncodedString()
        
        return "\(ivBase64):\(encryptedBase64)"
    }
    
    static func decrypt(_ encryptedText: String) throws -> String {
        let parts = encryptedText.split(separator: ":")
        guard parts.count == 2 else {
            throw EncryptionError.invalidFormat
        }
        
        guard let ivData = Data(base64Encoded: String(parts[0])),
              let combinedData = Data(base64Encoded: String(parts[1])) else {
            throw EncryptionError.invalidFormat
        }
        
        // Extract encrypted data (remove IV from combined)
        // Format: combined contains [IV][encrypted]
        let encryptedData = combinedData.dropFirst(ivSize)
        
        let key = prepareKey(encryptionKey)
        
        var decryptedData = [UInt8](repeating: 0, count: encryptedData.count)
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = CCCrypt(
            CCOperation(kCCDecrypt),
            algorithm,
            options,
            key,
            keySize,
            Array(ivData),
            Array(encryptedData),
            encryptedData.count,
            &decryptedData,
            decryptedData.count,
            &numBytesDecrypted
        )
        
        guard cryptStatus == kCCSuccess else {
            throw EncryptionError.decryptionFailed
        }
        
        let decrypted = Data(decryptedData.prefix(Int(numBytesDecrypted)))
        guard let plainText = String(data: decrypted, encoding: .utf8) else {
            throw EncryptionError.decryptionFailed
        }
        
        return plainText
    }
    
    private static func prepareKey(_ key: String) -> [UInt8] {
        let keyData = key.data(using: .utf8) ?? Data()
        var keyBytes = [UInt8](keyData)
        
        if keyBytes.count < keySize {
            keyBytes.append(contentsOf: [UInt8](repeating: 0, count: keySize - keyBytes.count))
        } else if keyBytes.count > keySize {
            keyBytes = Array(keyBytes.prefix(keySize))
        }
        
        return keyBytes
    }
}

enum EncryptionError: Error {
    case invalidInput
    case invalidFormat
    case keyGenerationFailed
    case encryptionFailed
    case decryptionFailed
    
    var localizedDescription: String {
        switch self {
        case .invalidInput:
            return "Invalid input data"
        case .invalidFormat:
            return "Invalid encrypted data format"
        case .keyGenerationFailed:
            return "Failed to generate encryption key"
        case .encryptionFailed:
            return "Encryption failed"
        case .decryptionFailed:
            return "Decryption failed"
        }
    }
}

