package com.rajendra.sketchide.editor.dialogs

import android.content.Context
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.ListView


class EnumDialog(context: Context, savedValue: String, arguments: ArrayList<String>) :
  AttributeDialog(context) {
  private val listview = ListView(context)

  private val arguments: List<String> = arguments

  init {
    // Set the view layout parameters
    listview.layoutParams = ViewGroup.LayoutParams(
      ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
    )
    // Set adapter
    listview.adapter = ArrayAdapter(
      context, android.R.layout.simple_list_item_single_choice, arguments
    )
    // Set choice mode
    listview.choiceMode = ListView.CHOICE_MODE_SINGLE
    // Remove divider
    listview.divider = null

    if (savedValue.isNotEmpty()) {
      listview.setItemChecked(arguments.indexOf(savedValue), true)
    }

    // Set view, and pass in padding arguments
    setView(listview, 0, 20, 0, 0)
  }

  /**
   * Overridden method from AttributeDialog class
   * Gets the listview checked item position, saves it
   * and passes the saved value to the listener
   */
  override fun onClickSave() {
    if (listview.checkedItemPosition == -1) {
      listener.onSave("-1")
      return
    }

    listener.onSave(arguments[listview.checkedItemPosition])
  }
}