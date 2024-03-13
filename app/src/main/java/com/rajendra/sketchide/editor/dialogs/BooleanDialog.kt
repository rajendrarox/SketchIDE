package com.rajendra.sketchide.editor.dialogs

import android.content.Context
import androidx.appcompat.widget.AppCompatRadioButton
import com.rajendra.sketchide.databinding.LayoutBooleanDialogBinding
import com.rajendra.sketchide.R

class BooleanDialog(context: Context, savedValue: String) : AttributeDialog(
  context
) {
  // Inflate the layout for this dialog
  private val binding: LayoutBooleanDialogBinding =
    LayoutBooleanDialogBinding.inflate(getDialog().layoutInflater)

  init {
    // Initialize radio buttons.json
    val rbTrue: AppCompatRadioButton = binding.rbTrue
    val rbFalse: AppCompatRadioButton = binding.rbFalse

    // Set view padding
    setView(binding.getRoot(), 10, 20, 10, 0)

    // Check radio button for previously saved value
    if (savedValue.isNotEmpty()) {
      if (savedValue == "true") {
        rbTrue.isChecked = true
      } else {
        rbFalse.isChecked = true
      }
    }
  }

  /**
   * Method called when save button is clicked
   */
  override fun onClickSave() {
    super.onClickSave()

    // Get the checked radio button id
    val checkedRadioButtonId: Int = binding.root.checkedRadioButtonId

    // Check if radio button is true or false
    val value = if (checkedRadioButtonId == R.id.rbTrue) "true" else "false"

    // Invoke the listener to save the value
    listener.onSave(value)
  }
}