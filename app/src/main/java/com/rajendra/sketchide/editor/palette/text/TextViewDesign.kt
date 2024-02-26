package com.rajendra.sketchide.editor.palette.text

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.util.AttributeSet
import android.widget.TextView
import com.rajendra.sketchide.utils.Utils

@SuppressLint("AppCompatCustomView")
class TextViewDesign @JvmOverloads constructor(
  context: Context, attrs: AttributeSet? = null
) : TextView(context, attrs) {

  @set:JvmName("setStrokeEnabled")
  var drawStroke: Boolean = true
    set(value) {
      field = value
      invalidate()
    }

  @set:JvmName("setBlueprint")
  var isBlueprint: Boolean = false
    set(value) {
      field = value
      invalidate()
    }

  override fun dispatchDraw(canvas: Canvas) {
    super.dispatchDraw(canvas)

    if (drawStroke) Utils.drawBorder(this, canvas, isBlueprint)
  }

  override fun draw(canvas: Canvas) {
    if (isBlueprint) Utils.drawBorder(this, canvas, true)
    else super.draw(canvas)
  }
}