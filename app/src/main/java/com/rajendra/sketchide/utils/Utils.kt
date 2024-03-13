package com.rajendra.sketchide.utils

import android.Manifest
import android.Manifest.permission
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Canvas
import android.graphics.DashPathEffect
import android.graphics.Paint
import android.graphics.Point
import android.view.View
import androidx.core.content.ContextCompat
import com.blankj.utilcode.util.SizeUtils

object Utils {
  @JvmStatic
  fun drawDashedLine(
    canvas: Canvas,
    start: Point,
    end: Point,
    color: Int,
    dashWidth: Float,
    dashGap: Float
  ) {
    val dashPathEffect = DashPathEffect(floatArrayOf(dashWidth, dashGap), 0f)
    val paint = Paint().apply {
      this.color = color
      pathEffect = dashPathEffect
      style = Paint.Style.STROKE
      strokeWidth = SizeUtils.dp2px(2f).toFloat()
      isAntiAlias = true
    }
    canvas.drawRect(start.x.toFloat(), start.y.toFloat(), end.x.toFloat(), end.y.toFloat(), paint)
  }

  @JvmStatic
  fun drawBorder(view: View, canvas: Canvas, isBlueprint: Boolean) {
    drawDashedLine(
      canvas,
      Point(0, 0),
      Point(view.width, view.height),
      if (isBlueprint) Constants.BLUEPRINT_BORDER_COLOR else Constants.DESIGN_BORDER_COLOR,
      7f,
      5f
    )
  }

  @JvmStatic
  fun isPermissionGranted(context: Context): Boolean {
    return (ContextCompat.checkSelfPermission(
      context,
      permission.READ_EXTERNAL_STORAGE
    ) == PackageManager.PERMISSION_GRANTED) && (ContextCompat.checkSelfPermission(
      context,
      permission.WRITE_EXTERNAL_STORAGE
    ) == PackageManager.PERMISSION_GRANTED)
  }
}