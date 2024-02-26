package com.rajendra.sketchide.utils

import android.content.Context

object FileUtils {
  @JvmStatic
  fun readFromAssets(context: Context, fileName: String): String {
    return context.assets.open(fileName).bufferedReader().use { it.readText() }
  }
}