package com.rajendra.sketchide.editor.dialogs

import android.content.Context
import android.text.Editable
import android.text.TextWatcher
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textfield.TextInputLayout
import com.rajendra.sketchide.databinding.TextinputlayoutBinding
import com.rajendra.sketchide.managers.IdManager.getIds
import java.util.regex.Pattern


class IdDialog(context: Context?, savedValue: String) : AttributeDialog(
  context!!
) {
  private val textInputLayout: TextInputLayout
  private val textInputEditText: TextInputEditText

  private val ids: MutableList<String>

  init {
    // Initialize the binding and savedValue variables
    val binding: TextinputlayoutBinding = TextinputlayoutBinding.inflate(getDialog().layoutInflater)

    // Get all the IDs from the IdManager
    ids = getIds()

    // Initialize the TextInputLayout and set hint and prefix text
    textInputLayout = binding.getRoot()
    textInputLayout.hint = "Enter new ID"
    textInputLayout.prefixText = "@+id/"

    // Initialize the TextInputEditText and set the text from the savedValue
    textInputEditText = binding.textinputEdittext
    if (savedValue.isNotEmpty()) {
      ids.remove(savedValue.replace("@+id/", ""))
      textInputEditText.setText(savedValue.replace("@+id/", ""))
    }

    // Add a TextWatcher to the TextInputEditText for checking errors
    textInputEditText.addTextChangedListener(
      object : TextWatcher {
        override fun beforeTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {}

        override fun onTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {}

        override fun afterTextChanged(p1: Editable) {
          checkErrors()
        }
      })

    // Set the view with a margin of 10dp
    setView(textInputLayout, 10)
    showKeyboardWhenOpen()
  }

  /**
   * Check errors in the TextInputEditText
   */
  private fun checkErrors() {
    val text = textInputEditText.text.toString()

    // Check if the TextInputEditText is empty
    if (text.isEmpty()) {
      textInputLayout.isErrorEnabled = true
      textInputLayout.error = "Field cannot be empty!"
      setPositiveButtonEnabled(false)
      return
    }

    // Check if the text matches the pattern of only small letters(a-z) and numbers
    if (!Pattern.matches("[a-z_][a-z0-9_]*", text)) {
      textInputLayout.isErrorEnabled = true
      textInputLayout.error = "Only small letters(a-z) and numbers!"
      setPositiveButtonEnabled(false)
      return
    }

    // Check if the ID is already taken
    for (id in ids) {
      if (id == text) {
        textInputLayout.isErrorEnabled = true
        textInputLayout.error = "Current ID is unavailable!"
        setPositiveButtonEnabled(false)
        return
      }
    }

    // No errors detected
    textInputLayout.isErrorEnabled = false
    textInputLayout.error = ""
    setPositiveButtonEnabled(true)
  }

  override fun show() {
    super.show()

    // Request focus to the TextInputEditText and check errors
    requestEdittext(textInputEditText)
    checkErrors()
  }

  override fun onClickSave() {
    // Call the onSave method and pass the ID
    listener.onSave("@+id/" + textInputEditText.text.toString())
  }
}