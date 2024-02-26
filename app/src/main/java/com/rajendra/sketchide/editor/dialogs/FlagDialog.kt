package com.rajendra.sketchide.editor.dialogs

import android.content.Context
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.ListView

class FlagDialog(context: Context, savedValue: String, arguments: ArrayList<String>) :
  AttributeDialog(context) {
  // Declaring a ListView object

  // Initializing listview
  private val listview = ListView(context)

  // Declaring a List object to store arguments
  // Assigning arguments to the List object
  private val arguments: List<String> = arguments

  init {
    // Setting the layout params
    listview.layoutParams = ViewGroup.LayoutParams(
      ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
    )

    // Setting multiple choice mode for listview
    listview.choiceMode = ListView.CHOICE_MODE_MULTIPLE

    // Setting adapter to listview
    listview.adapter = ArrayAdapter(
      context, android.R.layout.simple_list_item_multiple_choice, arguments
    )

    // Setting divider to null
    listview.divider = null

    // Checking if the savedValue is not empty
    if (savedValue.isNotEmpty()) {
      // Splitting the savedValue using | as the delimiter
      val flags = savedValue.split("\\|".toRegex()).dropLastWhile { it.isEmpty() }
        .toTypedArray()

      // Looping through the flags array
      for (flag in flags) {
        // Getting the index of the flag in the arguments list
        val index = arguments.indexOf(flag)

        // Setting the listview item at the index as checked
        listview.setItemChecked(index, true)
      }
    }

    // Setting padding around the listview
    setView(listview, 0, 20, 0, 0)
  }

  /** Overriding the superclass's method to save the data  */
  override fun onClickSave() {
    // Calling the superclass's method
    super.onClickSave()

    // Checking if no item is checked in the listview
    if (listview.checkedItemCount == 0) {
      // Passing -1 as the saved value
      listener.onSave("-1")

      // Returning
      return
    }

    // Creating a StringBuilder object
    val builder = StringBuilder()

    // Getting the checked item positions
    val array = listview.checkedItemPositions

    // Looping through the array
    for (i in 0 until array.size()) {
      // Getting the checked item
      val checkedItem = array.keyAt(i)

      // Checking if the item is checked
      if (array[checkedItem]) {
        // Appending the checked item's argument in the arguments list to the StringBuilder object
        builder.append(arguments[checkedItem]).append("|")
      }
    }

    // Converting the StringBuilder object to String object
    var value = builder.toString()

    // Removing the last | from the String object
    value = value.substring(0, value.lastIndexOf("|"))

    // Passing the String object as the saved value
    listener.onSave(value)
  }
}