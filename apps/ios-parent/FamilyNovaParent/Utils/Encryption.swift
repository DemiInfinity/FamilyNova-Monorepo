//
//  Encryption.swift
//  FamilyNovaParent
//

import Foundation
import CommonCrypto
import CryptoKit

class Encryption {
    // Encryption key - should match backend key
    // In production, this should be stored securely (Keychain)
    private static let encryptionKey: String = {
        // Get from environment or use default (should match backend)
        // For production, store in Keychain or secure storage
        if let key = ProcessInfo.processInfo.environment["ENCRYPTION_KEY"] {
            return key
        }
        // Default key - MUST match backend ENCRYPTION_KEY
        // This should be set via environment variable or secure storage
        // Production: Store in Keychain for better security
        return "89818c2bcf3c17e6b20cf097d0997f5a043267b797fe32c753f5d809cdc941f7"
    }()
    
    private static let algorithm: CCAlgorithm = CCAlgorithm(kCCAlgorithmAES)
    private static let keySize = kCCKeySizeAES256
    private static let ivSize = kCCBlockSizeAES128
    private static let options = CCOptions(kCCOptionPKCS7Padding)
    
    /**
     * Encrypts data using AES-256
     * Returns format: iv:encryptedData (both base64)
     */
    static func encrypt(_ plainText: String) throws -> String {
        guard let data = plainText.data(using: .utf8) else {
            throw EncryptionError.invalidInput
        }
        
        // Prepare key
        let key = prepareKey(encryptionKey)
        
        // Generate random IV
        var iv = [UInt8](repeating: 0, count: ivSize)
        let status = SecRandomCopyBytes(kSecRandomDefault, ivSize, &iv)
        guard status == errSecSuccess else {
            throw EncryptionError.keyGenerationFailed
        }
        
        // Encrypt
        var encryptedData = [UInt8](repeating: 0, count: data.count + ivSize)
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = CCCrypt(
            CCOperation(kCCEncrypt),
            CCAlgorithm(kCCAlgorithmAES),
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
        
        // Combine IV and encrypted data
        let combined = iv + Array(encryptedData.prefix(Int(numBytesEncrypted)))
        let combinedData = Data(combined)
        
        // Return as base64: iv:encryptedData
        let ivBase64 = Data(iv).base64EncodedString()
        let encryptedBase64 = combinedData.base64EncodedString()
        
        // For GCM mode, we'd need to include auth tag, but for simplicity using CBC
        // Format: iv:encryptedData
        return "\(ivBase64):\(encryptedBase64)"
    }
    
    /**
     * Decrypts data
     * Expects format: iv:encryptedData (both base64)
     */
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
            CCAlgorithm(kCCAlgorithmAES),
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
    
    /**
     * Prepares encryption key (32 bytes for AES-256)
     * Matches backend: if key is 64 hex chars, use directly; otherwise hash with SHA256
     */
    private static func prepareKey(_ key: String) -> [UInt8] {
        // Check if key is a 64-character hex string (32 bytes)
        let hexChars = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        if key.count == 64 && key.unicodeScalars.allSatisfy({ hexChars.contains($0) }) {
            // Convert hex string to bytes
            var keyBytes: [UInt8] = []
            var index = key.startIndex
            while index < key.endIndex {
                let nextIndex = key.index(index, offsetBy: 2, limitedBy: key.endIndex) ?? key.endIndex
                if let byte = UInt8(key[index..<nextIndex], radix: 16) {
                    keyBytes.append(byte)
                }
                index = nextIndex
            }
            return keyBytes
        } else {
            // Hash the key string with SHA256 (matches backend behavior)
            let keyData = key.data(using: .utf8) ?? Data()
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            keyData.withUnsafeBytes { bytes in
                _ = CC_SHA256(bytes.baseAddress, CC_LONG(keyData.count), &digest)
            }
            return digest
        }
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

