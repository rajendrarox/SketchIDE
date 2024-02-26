package com.rajendra.sketchide.utils.parser

import android.view.View
import android.view.ViewGroup
import android.widget.CalendarView
import android.widget.SearchView
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.android.material.navigation.NavigationView
import com.google.android.material.tabs.TabLayout
import com.rajendra.sketchide.editor.AttributeMap
import com.rajendra.sketchide.editor.EditorLayout
import org.apache.commons.text.StringEscapeUtils

class XmlLayoutGenerator() {
  private val builder: StringBuilder = StringBuilder()
  private var tab: String = "\t"

  private var useSuperclasses: Boolean = false

  fun generate(editor: EditorLayout, useSuperclasses: Boolean): String {
    this.useSuperclasses = useSuperclasses

    if (editor.childCount == 0) {
      return ""
    }
    builder.append("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n")

    return peek(editor.getChildAt(0), editor.viewAttributeMap, 0)
  }

  private fun peek(view: View?, attributeMap: HashMap<View, AttributeMap>, depth: Int): String {
    if (view == null) return ""
    val indent = getIndent(depth)
    var nextDepth = depth

    var className =
      if (useSuperclasses) view.javaClass.superclass.name else view.javaClass.name

    if (useSuperclasses) {
      if (className.startsWith("android.widget")) {
        className = view.javaClass.superclass.name
      }
    }

    builder.append("$indent<$className\n")

    if (depth == 0) {
      builder.append("${tab}xmlns:android=\"http://schemas.android.com/apk/res/android\"\n")
      builder.append("${tab}xmlns:app=\"http://schemas.android.com/apk/res-auto\"\n")
    }

    val keys =
      if ((attributeMap[view] != null)) attributeMap[view]!!.keySet() else ArrayList()
    val values =
      if ((attributeMap[view] != null)) attributeMap[view]!!.values() else ArrayList()
    for (key: String in keys) {
      builder.append(
        "$tab$indent$key=\"${StringEscapeUtils.escapeXml11(attributeMap[view]?.get(key))}\"\n"
      )
    }

    builder.deleteCharAt(builder.length - 1)

    if (view is ViewGroup) {
      if ((view !is CalendarView
          && view !is SearchView
          && view !is NavigationView
          && view !is BottomNavigationView
          && view !is TabLayout)
      ) {
        nextDepth++

        if (view.childCount > 0) {
          builder.append(">\n\n")

          for (i in 0 until view.childCount) {
            peek(view.getChildAt(i), attributeMap, nextDepth)
          }

          builder.append("$indent</$className>\n\n")
        } else {
          builder.append(" />\n\n")
        }
      } else {
        builder.append(" />\n\n")
      }
    } else {
      builder.append(" />\n\n")
    }

    return builder.toString().trim { it <= ' ' }
  }

  private fun getIndent(depth: Int): String {
    return tab.repeat(depth)
  }
}