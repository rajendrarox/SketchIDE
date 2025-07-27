package com.sketchide.app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.sketchide.app/storage_permission"
    private val PERMISSION_REQUEST_CODE = 1001
    private var permissionCallback: MethodChannel.Result? = null
    private var isRequestingPermission = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkStoragePermission" -> {
                    val hasPermission = isStoragePermissionGranted()
                    result.success(hasPermission)
                }
                "requestStoragePermission" -> {
                    if (isRequestingPermission) {
                        result.error("ALREADY_REQUESTING", "Permission request already in progress", null)
                        return@setMethodCallHandler
                    }
                    
                    if (isStoragePermissionGranted()) {
                        result.success(true)
                        return@setMethodCallHandler
                    }
                    
                    permissionCallback = result
                    isRequestingPermission = true
                    requestStoragePermission()
                }
                "openAppSettings" -> {
                    openAppSettings()
                    result.success(null)
                }
                "getExternalStoragePath" -> {
                    val path = Environment.getExternalStorageDirectory().absolutePath
                    result.success(path)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isStoragePermissionGranted(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11+ - check for MANAGE_EXTERNAL_STORAGE
            Environment.isExternalStorageManager()
        } else {
            // Android 10 and below - check for READ/WRITE permissions
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun requestStoragePermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11+ - request MANAGE_EXTERNAL_STORAGE
            try {
                val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                intent.data = Uri.parse("package:$packageName")
                startActivity(intent)
                // Note: We can't detect when user returns from settings, so we'll rely on Flutter to check again
            } catch (e: Exception) {
                // Fallback to general storage settings
                val intent = Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
                startActivity(intent)
            }
        } else {
            // Android 10 and below - request READ/WRITE permissions
            val permissions = arrayOf(
                Manifest.permission.READ_EXTERNAL_STORAGE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE
            )
            ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE)
        }
    }

    private fun openAppSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.parse("package:$packageName")
        startActivity(intent)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            if (allGranted) {
                permissionCallback?.success(true)
            } else {
                permissionCallback?.success(false)
            }
            permissionCallback = null
            isRequestingPermission = false
        }
    }

    override fun onResume() {
        super.onResume()
        // Check if permission was granted while in settings (for Android 11+)
        if (isRequestingPermission && isStoragePermissionGranted()) {
            permissionCallback?.success(true)
            permissionCallback = null
            isRequestingPermission = false
        }
    }
} 