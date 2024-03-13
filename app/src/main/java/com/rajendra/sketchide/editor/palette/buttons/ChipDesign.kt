package com.rajendra.sketchide.editor.palette.buttons

import android.content.Context
import android.graphics.Canvas
import android.util.AttributeSet
import com.google.android.material.chip.Chip
import com.rajendra.sketchide.utils.Utils

class ChipDesign @JvmOverloads constructor(
  context: Context, attrs: AttributeSet? = null
) : Chip(context, attrs) {
  private var drawStroke = true
  private var isBlueprint = false

  override fun dispatchDraw(canvas: Canvas) {
    super.dispatchDraw(canvas)

    if (drawStroke) Utils.drawBorder(this, canvas, isBlueprint)
  }

  override fun draw(canvas: Canvas) {
    if (isBlueprint) Utils.drawBorder(this, canvas, true)
    else super.draw(canvas)
  }

  fun setStrokeEnabled(enabled: Boolean) {
    drawStroke = enabled
    invalidate()
  }

  fun setBlueprint(enabled: Boolean) {
    isBlueprint = enabled
    invalidate()
  }
}