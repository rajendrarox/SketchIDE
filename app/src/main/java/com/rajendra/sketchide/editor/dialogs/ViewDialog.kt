package com.rajendra.sketchide.editor.dialogs

import android.content.Context
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.ListView
import com.rajendra.sketchide.managers.IdManager.getIds

class ViewDialog(context: Context, savedValue: String, private val constant: String?) :
  AttributeDialog(context) {
  private val ids: MutableList<String> = ArrayList()
  private val listview: ListView

  init {
    ids.addAll(getIds())

    if (constant != null) {
      ids.add(0, constant)
    }

    listview = ListView(context)
    listview.layoutParams = ViewGroup.LayoutParams(
      ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
    )
    listview.adapter =
      ArrayAdapter(context, android.R.layout.simple_list_item_single_choice, ids)
    listview.choiceMode = ListView.CHOICE_MODE_SINGLE
    listview.divider = null

    if (savedValue.isNotEmpty()) {
      listview.setItemChecked(ids.indexOf(savedValue.replace("@id/", "")), true)
    }

    setView(listview, 0, 20, 0, 0)
  }

  /** This method is called when the save button is clicked.  */
  override fun onClickSave() {
    super.onClickSave()
    if (listview.checkedItemPosition == -1) {
      listener.onSave("-1")
    } else {
      //	listener.onSave("@id/" + ids.get(listview.getCheckedItemPosition()));
      if (constant == null) {
        listener.onSave("@id/" + ids[listview.checkedItemPosition])
      } else {
        if (listview.checkedItemPosition > 0) {
          listener.onSave("@id/" + ids[listview.checkedItemPosition])
        } else {
          listener.onSave(constant)
        }
      }
    }
  }
}