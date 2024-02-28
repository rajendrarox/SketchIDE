package com.rajendra.sketchide.editor

import android.content.Context
import android.view.View
import com.rajendra.sketchide.utils.Constants
import com.rajendra.sketchide.utils.InvokeUtils

class AttributeInitializer @JvmOverloads constructor(
  private val context: Context,
  private val viewAttributeMap: HashMap<View, AttributeMap> = HashMap(),
  private val attributes: HashMap<String, List<HashMap<String, Any>>>,
  private val parentAttributes: HashMap<String, List<HashMap<String, Any>>>
) {

  fun applyDefaultAttributes(view: View, defaultAttrs: Map<String, String?>) {
    val allAttrs = getAllAttributesForView(view)

    for ((key, value) in defaultAttrs) {
      for (attr in allAttrs) {
        if (attr[Constants.KEY_ATTRIBUTE_NAME] == key) {
          applyAttributes(view, defaultAttrs[key]!!, attr)
        }
      }
    }
  }

  fun applyAttributes(view: View, value: String, attrs: HashMap<String, Any>) {
    val methodName = attrs[Constants.KEY_METHOD_NAME].toString()
    val className = attrs[Constants.KEY_CLASS_NAME].toString()
    val attributeName = attrs[Constants.KEY_ATTRIBUTE_NAME].toString()

    if (value.startsWith("@+id/") && viewAttributeMap[view]!!.containsKey("android:id")) {
      for (v in viewAttributeMap.keys) {
        val map = viewAttributeMap[v]!!

        for (key in map.keySet()) {
          val valuee = map[key]!!

          if (
            valuee.startsWith("@id/") &&
            valuee == viewAttributeMap[view]!!["android:id"]!!.replace(
              "+",
              ""
            )
          ) {
            map.put(key, value.replace("+", ""))
          }
        }
      }
    }

    viewAttributeMap[view]!!.put(attributeName, value)

    InvokeUtils.invokeMethod(methodName, className, view, value, context)
  }

  fun getAvailableAttributesForView(view: View): List<HashMap<String, Any>> {
    val keys = viewAttributeMap[view]!!.keySet()
    val allAttrs = getAllAttributesForView(view)

    return allAttrs.filter { keys.none { key -> key == it[Constants.KEY_ATTRIBUTE_NAME].toString() } }
  }

  @Suppress("UNCHECKED_CAST")
  fun getAllAttributesForView(view: View): MutableList<HashMap<String, Any>> {
    val allAttrs = mutableListOf<HashMap<String, Any>>()

    var cls = view.javaClass
    val viewParentCls = View::class.java.superclass

    while (cls != viewParentCls) {
      if (attributes.containsKey(cls.name)) {
        allAttrs.addAll(0, attributes[cls.name]!!)
      }
      cls = cls.superclass as Class<View>
    }

    if (view.parent != null && view.parent.javaClass != EditorLayout::class.java) {
      cls = view.parent.javaClass as Class<View>

      while (cls != viewParentCls) {
        if (parentAttributes.containsKey(cls.name)) {
          allAttrs.addAll(0, parentAttributes[cls.name]!!)
        }
        cls = cls.superclass as Class<View>
      }
    }

    return allAttrs
  }

  fun getAttributeFromKey(
    key: String,
    list: MutableList<HashMap<String, Any>>
  ): HashMap<String, Any> {
    return list.first { it[Constants.KEY_ATTRIBUTE_NAME] == key }
  }

}