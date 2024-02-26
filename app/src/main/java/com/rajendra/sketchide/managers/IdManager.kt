package com.rajendra.sketchide.managers

import android.view.View
import android.view.ViewGroup

object IdManager {
  @get:JvmStatic
  val idMap = HashMap<View, String>()

  @JvmStatic
  fun addNewId(view: View, id: String) {
    if (!idMap.containsKey(view)) {
      view.id = View.generateViewId()
    }
    idMap[view] = id.replace("@+id/", "")
  }

  @JvmStatic
  fun addId(view: View, idName: String, id: Int) {
    view.id = id
    idMap[view] = idName.replace("@+id/", "")
  }

  @JvmStatic
  fun removeId(view: View, removeChilds: Boolean) {
    idMap.remove(view)
    if (removeChilds && view is ViewGroup) {
      for (i in 0 until view.childCount) {
        removeId(view.getChildAt(i), true)
      }
    }
  }

  @JvmStatic
  fun containsId(name: String): Boolean {
    val mName = name.replace("@+id/", "")
    return idMap.containsValue(mName)
  }

  @JvmStatic
  fun clear() {
    idMap.clear()
  }

  @JvmStatic
  fun getViewId(name: String): Int {
    val mName = name.replace("@+id/", "")
    for (view in idMap.keys) {
      if (idMap[view] == mName) {
        return view.id
      }
    }
    return -1
  }

  @JvmStatic
  fun getIds(): MutableList<String> {
    return idMap.values.toMutableList()
  }
}