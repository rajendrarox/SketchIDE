package com.rajendra.sketchide.editor.dialogs

import android.content.Context
import android.view.View
import android.view.WindowManager
import android.view.inputmethod.InputMethodManager
import androidx.appcompat.app.AlertDialog
import com.blankj.utilcode.util.SizeUtils
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.google.android.material.textfield.TextInputEditText
import com.rajendra.sketchide.editor.dialogs.interfaces.OnSaveValueListener

open class AttributeDialog(
  private val context: Context
) {

  private val dialog: AlertDialog = MaterialAlertDialogBuilder(context).create()
  private val inputMethodManager: InputMethodManager

  protected lateinit var listener: OnSaveValueListener

  init {
    dialog.apply {
      setButton(AlertDialog.BUTTON_POSITIVE, "Save") { _, _ -> onClickSave() }
      setButton(AlertDialog.BUTTON_NEGATIVE, "Cancel") { _, _ -> }
    }

    inputMethodManager =
      context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
  }

  fun setTitle(title: String) = dialog.setTitle(title)

  fun setMessage(message: String) = dialog.setMessage(message)

  fun setView(view: View) = dialog.setView(view)

  fun setView(view: View, padding: Int) {
    val pad = SizeUtils.dp2px(padding.toFloat())
    dialog.setView(view, pad, pad, pad, pad)
  }

  fun setView(view: View, left: Int, top: Int, right: Int, bottom: Int) {
    dialog.setView(
      view,
      SizeUtils.dp2px(left.toFloat()),
      SizeUtils.dp2px(top.toFloat()),
      SizeUtils.dp2px(right.toFloat()),
      SizeUtils.dp2px(bottom.toFloat())
    )
  }

  open fun show() {
    dialog.show()
  }

  fun setPositiveButtonEnabled(enabled: Boolean) {
    dialog.getButton(AlertDialog.BUTTON_POSITIVE).isEnabled = enabled
  }

  protected fun showKeyboardWhenOpen() {
    dialog.window?.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE)
  }

  protected fun requestEdittext(editText: TextInputEditText) {
    editText.requestFocus()
    inputMethodManager.showSoftInput(editText, InputMethodManager.SHOW_IMPLICIT)

    if (editText.text?.isNotEmpty() == true) {
      editText.setSelection(0, editText.text?.length ?: 0)
    }
  }

  protected fun getString(id: Int) = context.getString(id)

  protected open fun onClickSave() {}

  fun setOnSaveValueListener(listener: OnSaveValueListener) {
    this.listener = listener
  }

  fun getDialog() = dialog
}