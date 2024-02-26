package com.rajendra.sketchide.editor.dialogs

import android.content.Context
import android.text.Editable
import android.text.InputType
import android.text.TextWatcher
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textfield.TextInputLayout
import com.rajendra.sketchide.databinding.TextinputlayoutBinding

class NumberDialog(context: Context, savedValue: String, type: String) :
  AttributeDialog(context) {
  private val textInputLayout: TextInputLayout
  private val textInputEditText: TextInputEditText

  init {
    val binding: TextinputlayoutBinding = TextinputlayoutBinding.inflate(getDialog().layoutInflater)

    textInputLayout = binding.getRoot()
    textInputLayout.hint = "Enter $type value"

    textInputEditText = binding.textinputEdittext

    if (type == "float") {
      // Set input type to signed float
      textInputEditText.inputType = (InputType.TYPE_CLASS_NUMBER
        or InputType.TYPE_NUMBER_FLAG_SIGNED
        or InputType.TYPE_NUMBER_FLAG_DECIMAL)
    } else {
      // Set input type to signed integer
      textInputEditText.inputType = InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_SIGNED
    }

    // If no saved value, set to 0
    textInputEditText.setText(savedValue.ifEmpty { "0" })
    textInputEditText.addTextChangedListener(
      object : TextWatcher {
        override fun beforeTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {}

        override fun onTextChanged(text: CharSequence, p2: Int, p3: Int, p4: Int) {}

        // Check for error on text change
        override fun afterTextChanged(p1: Editable) {
          checkError()
        }
      })

    // Set padding of the view
    setView(textInputLayout, 10)
    showKeyboardWhenOpen()
  }

  /** Show the dialog, and request focus in edit text  */
  override fun show() {
    super.show()
    requestEdittext(textInputEditText)
  }

  /** On clicking save, invoke listener's onSave method  */
  override fun onClickSave() {
    listener.onSave(textInputEditText.text.toString())
  }

  /** Check for error. Set enabled to false if empty and set error message  */
  private fun checkError() {
    val text = textInputEditText.text.toString()

    if (text.isEmpty()) {
      setPositiveButtonEnabled(false)
      textInputLayout.isErrorEnabled = true
      textInputLayout.error = "Field cannot be empty!"
    } else {
      setPositiveButtonEnabled(true)
      textInputLayout.isErrorEnabled = false
      textInputLayout.error = ""
    }
  }
}