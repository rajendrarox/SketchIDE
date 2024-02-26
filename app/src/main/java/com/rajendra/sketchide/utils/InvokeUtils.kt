package com.rajendra.sketchide.utils

import android.content.Context
import android.util.Log
import android.view.View
import com.rajendra.sketchide.R

object InvokeUtils {
  fun invokeMethod(
    methodName: String,
    className: String,
    view: View,
    value: String,
    context: Context
  ) {
    try {
      val clazz = Class.forName("com.rajendra.sketchide.editor.palette.callers.$className")
      val method =
        clazz.getMethod(methodName, View::class.java, String::class.java, Context::class.java)
      method.invoke(clazz, view, value, context)
    } catch (e: ClassNotFoundException) {
      e.printStackTrace()
      Log.e("InvokeUtils", "Class not found: $className")
    } catch (e: NoSuchMethodException) {
      e.printStackTrace()
      Log.e("InvokeUtils", "Method not found: $methodName")
    } catch (e: Exception) {
      e.printStackTrace()
      Log.e("InvokeUtils", "Error invoking method: $methodName")
    }
  }

  fun createView(viewName: String, context: Context): View {
    try {
      val clazz = Class.forName(viewName)
      val constructor = clazz.getConstructor(Context::class.java)
      return constructor.newInstance(context) as View
    } catch (e: ClassNotFoundException) {
      e.printStackTrace()
      Log.e("InvokeUtils", "Class not found: $viewName")
      throw e
    }
  }

  @JvmStatic
  fun getMipmapId(name: String): Int {
    try {
      val cls = R.mipmap::class.java
      val field = cls.getField(name)
      return field.getInt(cls)
    } catch (e: NoSuchFieldException) {
      e.printStackTrace()
    } catch (e: IllegalAccessException) {
      e.printStackTrace()
    }

    return 0
  }

  @JvmStatic
  fun getSuperClassName(clazz: String): String? {
    return try {
      Class.forName(clazz).superclass.name
    } catch (e: ClassNotFoundException) {
      null
    }
  }
}