package com.rajendra.sketchide

import android.app.Application
import com.google.android.material.color.DynamicColors

class SketchIDE : Application() {
  override fun onCreate() {
    super.onCreate()
    DynamicColors.applyToActivitiesIfAvailable(this)
  }
}