package com.rajendra.sketchide.editor.palette.callers

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.view.View
import com.rajendra.sketchide.managers.IdManager.addNewId
import com.rajendra.sketchide.utils.ArgumentUtil
import com.rajendra.sketchide.utils.Constants
import com.rajendra.sketchide.utils.DimensionUtil


object ViewCaller {
  fun setId(target: View?, value: String, context: Context) {
    addNewId(target!!, value)
  }

  fun setLayoutWidth(target: View, value: String, context: Context) {
    target.layoutParams.width = DimensionUtil.parse(value, context).toInt()
    target.requestLayout()
  }

  fun setLayoutHeight(target: View, value: String, context: Context) {
    target.layoutParams.height = DimensionUtil.parse(value, context).toInt()
    target.requestLayout()
  }

//  fun setBackground(target: View, value: String, context: Context?) {
//    if (ArgumentUtil.parseType(value, arrayOf<String>("color", "drawable")) == ArgumentUtil.COLOR
//    ) {
//      target.setBackgroundColor(Color.parseColor(value))
//    } else {
//      val name = value.replace("@drawable/", "")
//      target.background = DrawableManager.getDrawable(context, name)
//    }
//  }
//
//  fun setForeground(target: View, value: String, context: Context?) {
//    if (ArgumentUtil.parseType(value, arrayOf<String>("color", "drawable"))
//        .equals(ArgumentUtil.COLOR)
//    ) {
//      target.foreground = ColorDrawable(Color.parseColor(value))
//    } else {
//      val name = value.replace("@drawable/", "")
//      target.foreground = DrawableManager.getDrawable(context, name)
//    }
//  }

  fun setElevation(target: View, value: String, context: Context) {
    target.elevation = DimensionUtil.parse(value, context)
  }

  fun setAlpha(target: View, value: String, context: Context) {
    target.alpha = value.toFloat()
  }

  fun setRotation(target: View, value: String, context: Context) {
    target.rotation = value.toFloat()
  }

  fun setRotationX(target: View, value: String, context: Context) {
    target.rotationX = value.toFloat()
  }

  fun setRotationY(target: View, value: String, context: Context) {
    target.rotationY = value.toFloat()
  }

  fun setTranslationX(target: View, value: String, context: Context) {
    target.translationX = DimensionUtil.parse(value, context)
  }

  fun setTranslationY(target: View, value: String, context: Context) {
    target.translationY = DimensionUtil.parse(value, context)
  }

  fun setTranslationZ(target: View, value: String, context: Context) {
    target.translationZ = DimensionUtil.parse(value, context)
  }

  fun setScaleX(target: View, value: String, context: Context) {
    target.scaleX = value.toFloat()
  }

  fun setScaleY(target: View, value: String, context: Context) {
    target.scaleY = value.toFloat()
  }

  fun setPadding(target: View, value: String, context: Context) {
    val pad = DimensionUtil.parse(value, context).toInt()
    target.setPadding(pad, pad, pad, pad)
  }

  fun setPaddingLeft(target: View, value: String, context: Context) {
    val pad = DimensionUtil.parse(value, context).toInt()
    target.setPadding(
      pad, target.paddingTop, target.paddingRight, target.paddingBottom
    )
  }

  fun setPaddingRight(target: View, value: String, context: Context) {
    val pad = DimensionUtil.parse(value, context).toInt()
    target.setPadding(
      target.paddingLeft, target.paddingTop, pad, target.paddingBottom
    )
  }

  fun setPaddingTop(target: View, value: String, context: Context) {
    val pad = DimensionUtil.parse(value, context).toInt()
    target.setPadding(
      target.paddingLeft, pad, target.paddingRight, target.paddingBottom
    )
  }

  fun setPaddingBottom(target: View, value: String, context: Context) {
    val pad = DimensionUtil.parse(value, context).toInt()
    target.setPadding(
      target.paddingLeft, target.paddingTop, target.paddingRight, pad
    )
  }

  fun setEnabled(target: View, value: String, context: Context?) {
    if (value == "true") target.isEnabled = true
    else target.isEnabled = false
  }

  fun setVisibility(target: View, value: String, context: Context) {
    target.visibility = Constants.visibilityMap[value]!!
  }
}