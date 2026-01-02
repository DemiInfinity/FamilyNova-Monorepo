package com.nova.kids.ui.screens

import android.Manifest
import android.content.pm.PackageManager
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage
import com.nova.kids.design.CosmicColors
import com.nova.kids.design.CosmicSpacing
import java.util.concurrent.Executors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun QRCodeScannerScreen(
    onCodeScanned: (String) -> Unit,
    onDismiss: () -> Unit
) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current
    var hasPermission by remember { mutableStateOf(false) }
    var isScanning by remember { mutableStateOf(true) }
    
    val requestPermissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        hasPermission = isGranted
    }
    
    LaunchedEffect(Unit) {
        hasPermission = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED
        
        if (!hasPermission) {
            requestPermissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Scan QR Code") },
                navigationIcon = {
                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, "Close")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = CosmicColors.GlassBackground
                )
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .background(Color.Black)
        ) {
            if (!hasPermission) {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(CosmicSpacing.L),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Text(
                        "Camera permission is required to scan QR codes",
                        color = Color.White
                    )
                    Spacer(modifier = Modifier.height(CosmicSpacing.M))
                    Button(onClick = {
                        requestPermissionLauncher.launch(Manifest.permission.CAMERA)
                    }) {
                        Text("Grant Permission")
                    }
                }
            } else if (isScanning) {
                // Camera Preview with QR Code Scanning
                AndroidView(
                    factory = { ctx ->
                        val previewView = PreviewView(ctx)
                        val cameraProviderFuture = ProcessCameraProvider.getInstance(ctx)
                        
                        cameraProviderFuture.addListener({
                            val cameraProvider = cameraProviderFuture.get()
                            
                            val preview = Preview.Builder().build().also {
                                it.setSurfaceProvider(previewView.surfaceProvider)
                            }
                            
                            val imageAnalysis = ImageAnalysis.Builder()
                                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                                .build()
                            
                            val scanner = BarcodeScanning.getClient()
                            
                            imageAnalysis.setAnalyzer(Executors.newSingleThreadExecutor()) { imageProxy ->
                                if (!isScanning) {
                                    imageProxy.close()
                                    return@setAnalyzer
                                }
                                
                                val mediaImage = imageProxy.image
                                if (mediaImage != null) {
                                    val image = InputImage.fromMediaImage(
                                        mediaImage,
                                        imageProxy.imageInfo.rotationDegrees
                                    )
                                    
                                    scanner.process(image)
                                        .addOnSuccessListener { barcodes ->
                                            for (barcode in barcodes) {
                                                when (barcode.valueType) {
                                                    Barcode.TYPE_TEXT, Barcode.TYPE_URL -> {
                                                        val rawValue = barcode.rawValue ?: ""
                                                        // Extract code from QR string
                                                        val code = rawValue.replace("FAMILYNOVA:", "")
                                                        if (code.length == 6 || code.length == 8) {
                                                            isScanning = false
                                                            onCodeScanned(code)
                                                            onDismiss()
                                                        }
                                                    }
                                                    else -> {}
                                                }
                                            }
                                        }
                                        .addOnCompleteListener {
                                            imageProxy.close()
                                        }
                                } else {
                                    imageProxy.close()
                                }
                            }
                            
                            val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA
                            
                            try {
                                cameraProvider.unbindAll()
                                cameraProvider.bindToLifecycle(
                                    lifecycleOwner,
                                    cameraSelector,
                                    preview,
                                    imageAnalysis
                                )
                            } catch (e: Exception) {
                                e.printStackTrace()
                            }
                        }, ContextCompat.getMainExecutor(ctx))
                        
                        previewView
                    },
                    modifier = Modifier.fillMaxSize()
                )
                
                // Overlay with scanning frame
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(CosmicSpacing.M)
                    ) {
                        Text(
                            "Position the QR code within the frame",
                            color = Color.White
                        )
                    }
                }
            }
        }
    }
}
