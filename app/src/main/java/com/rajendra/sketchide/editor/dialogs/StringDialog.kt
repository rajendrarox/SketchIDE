package com.rajendra.sketchide.editor.dialogs

import android.content.Context
import android.text.Editable
import android.text.TextWatcher
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textfield.TextInputLayout
import com.rajendra.sketchide.databinding.TextinputlayoutBinding
import com.rajendra.sketchide.managers.DrawableManager
import com.rajendra.sketchide.managers.ProjectManager.Companion.instance
import com.rajendra.sketchide.utils.Constants
import java.util.regex.Pattern

class StringDialog(
  context: Context, savedValue: String?,
  /** Boolean flag to check if the dialog is for drawable  */
  var argumentType: String
) :
  AttributeDialog(context) {
  /** TextInputLayout object  */
  private val textInputLayout: TextInputLayout

  /** TextInputEditText object  */
  private val textInputEditText: TextInputEditText

  init {
    val binding: TextinputlayoutBinding = TextinputlayoutBinding.inflate(getDialog().layoutInflater)

    textInputLayout = binding.getRoot()
    textInputLayout.hint = "Enter string value"

    textInputEditText = binding.textinputEdittext
    textInputEditText.setText(savedValue)

    when (argumentType) {
      Constants.ARGUMENT_TYPE_DRAWABLE -> {
        textInputLayout.hint = "Enter drawable name"
        textInputLayout.prefixText = "@drawable/"
        textInputEditText.addTextChangedListener(
          object : TextWatcher {
            override fun beforeTextChanged(arg0: CharSequence, arg1: Int, arg2: Int, arg3: Int) {}

            override fun onTextChanged(arg0: CharSequence, arg1: Int, arg2: Int, arg3: Int) {}

            override fun afterTextChanged(arg0: Editable) {
              checkErrors()
            }
          })
      }

      Constants.ARGUMENT_TYPE_TEXT -> textInputLayout.hint = "Enter string value"
      Constants.ARGUMENT_TYPE_STRING -> {
        textInputLayout.hint = "Enter string name"
        textInputLayout.prefixText = "@string/"
        textInputEditText.addTextChangedListener(
          object : TextWatcher {
            override fun beforeTextChanged(arg0: CharSequence, arg1: Int, arg2: Int, arg3: Int) {}

            override fun onTextChanged(arg0: CharSequence, arg1: Int, arg2: Int, arg3: Int) {}

            override fun afterTextChanged(arg0: Editable) {
              checkErrors()
            }
          })
      }
    }
    setView(textInputLayout, 10)
    showKeyboardWhenOpen()
  }

  /** Method to check for errors  */
  private fun checkErrors() {
    val text = textInputEditText.text.toString()
    if (argumentType != Constants.ARGUMENT_TYPE_TEXT) {
      if (text.isEmpty()) {
        textInputLayout.isErrorEnabled = true
        textInputLayout.error = "Field cannot be empty!"
        setPositiveButtonEnabled(false)
        return
      }

      if (!Pattern.matches("[a-z_][a-z0-9_]*", text)) {
        textInputLayout.isErrorEnabled = true
        textInputLayout.error = "Only small letters(a-z) and numbers!"
        setPositiveButtonEnabled(false)
        return
      }
    }

    textInputLayout.isErrorEnabled = false
    textInputLayout.error = ""
    setPositiveButtonEnabled(true)
  }

  /** Method to show the dialog  */
  override fun show() {
    super.show()
    requestEdittext(textInputEditText)
    checkErrors()
  }

  /** Method to be invoked when the save button is clicked  */
  override fun onClickSave() {
    super.onClickSave()
    val text = textInputEditText.text.toString()
    when (argumentType) {
      Constants.ARGUMENT_TYPE_DRAWABLE -> listener.onSave("@drawable/$text")
      Constants.ARGUMENT_TYPE_STRING -> listener.onSave("@string/$text")
      Constants.ARGUMENT_TYPE_TEXT -> listener.onSave(text)
    }
  }
}