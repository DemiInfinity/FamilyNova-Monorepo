package com.example.familynova.utils;

import android.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.security.SecureRandom;

public class Encryption {
    // Encryption key - should match backend key
    // In production, store this securely (SharedPreferences with encryption or KeyStore)
    private static final String ENCRYPTION_KEY = "your-32-byte-encryption-key-here-must-match-backend";
    private static final String ALGORITHM = "AES";
    private static final String TRANSFORMATION = "AES/CBC/PKCS5Padding";
    private static final int IV_SIZE = 16; // 16 bytes for AES
    
    /**
     * Encrypts data using AES-256
     * Returns format: iv:encryptedData (both base64)
     */
    public static String encrypt(String plainText) throws Exception {
        // Prepare key (32 bytes for AES-256)
        byte[] keyBytes = prepareKey(ENCRYPTION_KEY);
        SecretKeySpec secretKey = new SecretKeySpec(keyBytes, ALGORITHM);
        
        // Generate random IV
        byte[] iv = new byte[IV_SIZE];
        SecureRandom random = new SecureRandom();
        random.nextBytes(iv);
        IvParameterSpec ivSpec = new IvParameterSpec(iv);
        
        // Encrypt
        Cipher cipher = Cipher.getInstance(TRANSFORMATION);
        cipher.init(Cipher.ENCRYPT_MODE, secretKey, ivSpec);
        byte[] encrypted = cipher.doFinal(plainText.getBytes("UTF-8"));
        
        // Combine IV and encrypted data
        byte[] combined = new byte[iv.length + encrypted.length];
        System.arraycopy(iv, 0, combined, 0, iv.length);
        System.arraycopy(encrypted, 0, combined, iv.length, encrypted.length);
        
        // Return as base64: iv:encryptedData
        String ivBase64 = Base64.encodeToString(iv, Base64.NO_WRAP);
        String encryptedBase64 = Base64.encodeToString(combined, Base64.NO_WRAP);
        
        return ivBase64 + ":" + encryptedBase64;
    }
    
    /**
     * Decrypts data
     * Expects format: iv:encryptedData (both base64)
     */
    public static String decrypt(String encryptedText) throws Exception {
        String[] parts = encryptedText.split(":");
        if (parts.length != 2) {
            throw new Exception("Invalid encrypted data format");
        }
        
        byte[] iv = Base64.decode(parts[0], Base64.NO_WRAP);
        byte[] encryptedData = Base64.decode(parts[1], Base64.NO_WRAP);
        
        // The encryptedData already has IV prepended, so we need to extract just the encrypted part
        // Format: encryptedData contains [IV][encrypted], we already have IV separately
        // So encryptedData should be the encrypted part only
        // Actually, looking at encrypt(), we combine IV + encrypted, so here we need to extract
        byte[] actualEncrypted = new byte[encryptedData.length - IV_SIZE];
        System.arraycopy(encryptedData, IV_SIZE, actualEncrypted, 0, actualEncrypted.length);
        
        // Prepare key
        byte[] keyBytes = prepareKey(ENCRYPTION_KEY);
        SecretKeySpec secretKey = new SecretKeySpec(keyBytes, ALGORITHM);
        IvParameterSpec ivSpec = new IvParameterSpec(iv);
        
        // Decrypt
        Cipher cipher = Cipher.getInstance(TRANSFORMATION);
        cipher.init(Cipher.DECRYPT_MODE, secretKey, ivSpec);
        byte[] decrypted = cipher.doFinal(actualEncrypted);
        
        return new String(decrypted, "UTF-8");
    }
    
    /**
     * Prepares encryption key (32 bytes for AES-256)
     */
    private static byte[] prepareKey(String key) {
        byte[] keyBytes = key.getBytes();
        byte[] finalKey = new byte[32]; // AES-256 requires 32 bytes
        
        if (keyBytes.length < 32) {
            // Pad with zeros
            System.arraycopy(keyBytes, 0, finalKey, 0, keyBytes.length);
            // Rest is already zeros
        } else {
            // Truncate to 32 bytes
            System.arraycopy(keyBytes, 0, finalKey, 0, 32);
        }
        
        return finalKey;
    }
}

