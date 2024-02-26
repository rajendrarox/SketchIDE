package com.rajendra.sketchide.utils.parser

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.rajendra.sketchide.editor.AttributeInitializer
import com.rajendra.sketchide.editor.AttributeMap
import com.rajendra.sketchide.managers.IdManager
import com.rajendra.sketchide.utils.Constants
import com.rajendra.sketchide.utils.FileUtils
import com.rajendra.sketchide.utils.InvokeUtils
import org.xmlpull.v1.XmlPullParser
import org.xmlpull.v1.XmlPullParserFactory
import java.io.StringReader

class XmlLayoutParser(val context: Context, val xml: String) {
  val viewAttributeMap: HashMap<View, AttributeMap> = HashMap()

  private val initializer: AttributeInitializer
  private val container: LinearLayout

  init {
    val attributes = Gson()
      .fromJson<HashMap<String, List<HashMap<String, Any>>>>(
        FileUtils.readFromAssets(context, Constants.ATTRIBUTES_FILE_NAME),
        object : TypeToken<HashMap<String, List<HashMap<String, Any>>>>() {}.type
      )
    val parentAttributes = Gson()
      .fromJson<HashMap<String, List<HashMap<String, Any>>>>(
        FileUtils.readFromAssets(context, Constants.PARENT_ATTRS_FILE_NAME),
        object : TypeToken<HashMap<String, List<HashMap<String, Any>>>>() {}.type
      )

    initializer = AttributeInitializer(context, attributes = attributes, parentAttributes = parentAttributes)
    container = LinearLayout(context).apply {
      layoutParams = LinearLayout.LayoutParams(
        LinearLayout.LayoutParams.WRAP_CONTENT,
        LinearLayout.LayoutParams.WRAP_CONTENT
      )
    }

    parse()
  }

  val root: View
    get() {
      val view = container.getChildAt(0)
      container.removeView(view)
      return view
    }

  private fun parse() {
    val viewsList = mutableListOf<View>()
    viewsList.add(container)

    try {
      val factory = XmlPullParserFactory.newInstance()
      val parser = factory.newPullParser()

      parser.apply {
        setFeature(XmlPullParser.FEATURE_PROCESS_NAMESPACES, false)
        setInput(StringReader(xml))
      }

      while (parser.eventType != XmlPullParser.END_DOCUMENT) {
        when (parser.eventType) {
          XmlPullParser.START_TAG -> {
            val view = InvokeUtils.createView(parser.name, context)
            viewsList.add(view)

            val attributeMap = AttributeMap()

            for (i in 0 until parser.attributeCount) {
              if (parser.getAttributeName(i).startsWith("xmlns").not()) {
                attributeMap.put(parser.getAttributeName(i), parser.getAttributeValue(i))
              }
            }

            viewAttributeMap[view] = attributeMap
          }

          XmlPullParser.END_TAG -> {
            val index = parser.depth
            (viewsList[index - 1] as ViewGroup).addView(viewsList[index])
            viewsList.removeAt(index)
          }
        }

        parser.next()
      }
    } catch (e: Exception) {
      e.printStackTrace()
    }

    IdManager.clear()

    for (view in viewAttributeMap.keys) {
      val map = viewAttributeMap[view]!!

      for (key in map.keySet()) {
        if (key == "android:id") {
          IdManager.addNewId(view, map["android:id"]!!)
        }
      }

      applyAttributes(view, map)
    }
  }

  private fun applyAttributes(view: View, attributeMap: AttributeMap) {
    val allAttributes = initializer.getAllAttributesForView(view)
    val keys = attributeMap.keySet()

    for (i in keys.indices.reversed()) {
      val key = keys[i]

      val attribute = initializer.getAttributeFromKey(key, allAttributes)
      val methodName = attribute[Constants.KEY_METHOD_NAME].toString()
      val className = attribute[Constants.KEY_CLASS_NAME].toString()
      val value = attributeMap[key].toString()

      if (key == "android:id") continue

      InvokeUtils.invokeMethod(methodName, className, view, value, view.context)
    }
  }
}