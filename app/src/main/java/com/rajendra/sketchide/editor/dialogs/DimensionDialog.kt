package com.rajendra.sketchide.editor.dialogs

import android.content.Context
import android.text.Editable
import android.text.InputType
import android.text.TextWatcher
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textfield.TextInputLayout
import com.rajendra.sketchide.databinding.TextinputlayoutBinding
import com.rajendra.sketchide.utils.DimensionUtil.getDimenWithoutSuffix

class DimensionDialog(context: Context, savedValue: String, private val unit: String) :
  AttributeDialog(context) {
  private val textInputLayout: TextInputLayout
  private val textInputEditText: TextInputEditText

  // Constructor to create a new instance of DimensionDialog
  init {
    // Inflate the textinputlayout layout
    val binding: TextinputlayoutBinding = TextinputlayoutBinding.inflate(getDialog().layoutInflater)

    // Get the root view of the textinputlayout
    textInputLayout = binding.getRoot()

    // Set the hint of the textInputLayout
    textInputLayout.hint = "Enter dimension value"

    // Set the suffix text of the textInputLayout
    textInputLayout.suffixText = unit

    // Get the textInputEditText
    textInputEditText = binding.textinputEdittext

    // Set the input type of the textInputEditText
    textInputEditText.inputType = InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_SIGNED

    // Set the saved value or default value 0
    textInputEditText.setText(
      if (savedValue.isEmpty()) "0" else getDimenWithoutSuffix(savedValue)
    )

    // Add TextWatcher to the textInputEditText to check the error
    textInputEditText.addTextChangedListener(
      object : TextWatcher {
        // Before text changed
        override fun beforeTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {}

        // On text changed
        override fun onTextChanged(text: CharSequence, p2: Int, p3: Int, p4: Int) {}

        // After text changed
        override fun afterTextChanged(p1: Editable) {
          checkError()
        }
      })

    // Set the view and margin to the dialog
    setView(textInputLayout, 10)

    // Show the keyboard when the dialog open
    showKeyboardWhenOpen()
  }

  override fun show() {
    super.show()
    // Request the focus on the textInputEditText
    requestEdittext(textInputEditText)
  }

  override fun onClickSave() {
    super.onClickSave()
    // Call the listener on save and append the unit
    listener.onSave(textInputEditText.text.toString() + unit)
  }

  // Method to check the error
  private fun checkError() {
    val text = textInputEditText.text.toString()

    // If the text is empty set the error and disable the save button
    if (text.isEmpty()) {
      setPositiveButtonEnabled(false)
      textInputLayout.isErrorEnabled = true
      textInputLayout.error = "Field cannot be empty!"
    } else {
      // Else enable the save button and remove the error
      setPositiveButtonEnabled(true)
      textInputLayout.isErrorEnabled = false
      textInputLayout.error = ""
    }
  }
}