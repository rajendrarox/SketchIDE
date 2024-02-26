package com.rajendra.sketchide.editor.dialogs

import android.animation.LayoutTransition
import android.annotation.SuppressLint
import android.content.Context
import android.text.Editable
import android.text.InputType
import android.text.TextWatcher
import android.view.View
import android.view.ViewGroup
import android.widget.RadioGroup
import androidx.appcompat.widget.AppCompatRadioButton
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textfield.TextInputLayout
import com.rajendra.sketchide.R
import com.rajendra.sketchide.databinding.LayoutSizeDialogBinding
import com.rajendra.sketchide.utils.DimensionUtil
import com.rajendra.sketchide.utils.DimensionUtil.getDimenWithoutSuffix

class SizeDialog(context: Context, savedValue: String) : AttributeDialog(
  context
) {
  private val textInputLayout: TextInputLayout
  private val textInputEditText: TextInputEditText

  private val group: RadioGroup

  init {
    val binding: LayoutSizeDialogBinding =
      LayoutSizeDialogBinding.inflate(getDialog().layoutInflater)

    val dialogView: ViewGroup = binding.getRoot()
    group = binding.radiogroup

    val rbMatchParent: AppCompatRadioButton = binding.rbMatchParent
    val rbWrapContent: AppCompatRadioButton = binding.rbWrapContent
    val rbFixedValue: AppCompatRadioButton = binding.rbFixedValue

    textInputLayout = dialogView.findViewById(R.id.textinput_layout)
    textInputLayout.hint = "Enter dimension value"
    textInputLayout.suffixText = "dp"

    textInputEditText = dialogView.findViewById(R.id.textinput_edittext)
    textInputEditText.inputType = InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_SIGNED
    textInputLayout.visibility = View.GONE

    // Check if savedValue is "match_parent", "wrap_content", or a fixed value
    if (savedValue.isNotEmpty()) {
      when (savedValue) {
        "match_parent" -> {
          rbMatchParent.isChecked = true
        }
        "wrap_content" -> {
          rbWrapContent.isChecked = true
        }
        else -> {
          rbFixedValue.isChecked = true
          textInputLayout.visibility = View.VISIBLE
          textInputEditText.setText(getDimenWithoutSuffix(savedValue))
        }
      }
    }

    // Add a TextChangeListener to the TextInputEditText to check for an error
    textInputEditText.addTextChangedListener(
      object : TextWatcher {
        override fun beforeTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {}

        override fun onTextChanged(text: CharSequence, p2: Int, p3: Int, p4: Int) {}

        override fun afterTextChanged(p1: Editable) {
          checkError()
        }
      })

    // Set onCheckedChangeListener to the RadioGroup
    group.setOnCheckedChangeListener { _: RadioGroup?, id: Int ->
      if (id == R.id.rb_fixed_value) {
        dialogView.layoutTransition = LayoutTransition()
        textInputLayout.visibility = View.VISIBLE
        checkError()
      } else {
        dialogView.layoutTransition = LayoutTransition()
        textInputLayout.visibility = View.GONE
        setPositiveButtonEnabled(true)
      }
    }

    setView(dialogView, 10)
  }

  /** Method to check for an error  */
  private fun checkError() {
    val text = textInputEditText.text.toString()

    // Check if the field is empty, and set the appropriate error messages
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

  /** Method to save the value of the attribute  */
  @SuppressLint("NonConstantResourceId")
  override fun onClickSave() {
    var value = ""

    // Get the value of the attribute based on the checked radio button
    val checkedRadioButtonId = group.checkedRadioButtonId
    when (checkedRadioButtonId) {
      R.id.rb_match_parent -> {
        value = "match_parent"
      }
      R.id.rb_wrap_content -> {
        value = "wrap_content"
      }
      R.id.rb_fixed_value -> {
        value = "${textInputEditText.text.toString()}${DimensionUtil.DP}"
      }
    }

    listener.onSave(value)
  }
}