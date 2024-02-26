package com.rajendra.sketchide.editor.dialogs

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.text.Editable
import android.text.InputFilter
import android.text.InputFilter.LengthFilter
import android.text.TextWatcher
import android.view.View
import android.widget.SeekBar
import android.widget.SeekBar.OnSeekBarChangeListener
import androidx.appcompat.widget.AppCompatSeekBar
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textfield.TextInputLayout
import com.rajendra.sketchide.R
import com.rajendra.sketchide.databinding.LayoutColorDialogBinding
import com.rajendra.sketchide.views.ColorView
import java.util.regex.Pattern

class ColorDialog(context: Context, savedValue: String) : AttributeDialog(
  context
), OnSeekBarChangeListener {
  // Declaring Views
  private val colorPreview: ColorView
  private val seekAlpha: AppCompatSeekBar
  private val seekRed: AppCompatSeekBar
  private val seekGreen: AppCompatSeekBar
  private val seekBlue: AppCompatSeekBar
  private val inputLayout: TextInputLayout
  private val aInputLayout: TextInputLayout
  private val rInputLayout: TextInputLayout
  private val gInputLayout: TextInputLayout
  private val bInputLayout: TextInputLayout
  private val editText: TextInputEditText
  private val aEdittext: TextInputEditText
  private val rEdittext: TextInputEditText
  private val gEdittext: TextInputEditText
  private val bEdittext: TextInputEditText

  init {
    // Inflate Layout Binding
    val binding = LayoutColorDialogBinding.inflate(getDialog().layoutInflater)

    // Getting View from binding
    val dialogView: View = binding.getRoot()

    // Initializing Views
    colorPreview = binding.colorPreview
    seekAlpha = binding.seekAlpha
    seekRed = binding.seekRed
    seekGreen = binding.seekGreen
    seekBlue = binding.seekBlue
    inputLayout = dialogView.findViewById(R.id.textinput_layout)
    aInputLayout = binding.ainputLayout
    rInputLayout = binding.rinputLayout
    gInputLayout = binding.ginputLayout
    bInputLayout = binding.binputLayout
    editText = dialogView.findViewById(R.id.textinput_edittext)
    aEdittext = binding.ainputEdittext
    rEdittext = binding.rinputEdittext
    gEdittext = binding.ginputEdittext
    bEdittext = binding.binputEdittext

    // Setting Seekbar Progress and Listener
    setSeekbarProgressAndListener(seekAlpha)
    setSeekbarProgressAndListener(seekRed)
    setSeekbarProgressAndListener(seekGreen)
    setSeekbarProgressAndListener(seekBlue)

    // Setting UI Values
    setUIValues(savedValue)

    // Setting TextWatcher on EditText
    setTextWatcherOnEditText()

    setView(dialogView, 10)
  }

  /**
   * Sets Seekbar Progress and Listener
   *
   * @param seekBar SeekBar to set
   */
  private fun setSeekbarProgressAndListener(seekBar: AppCompatSeekBar) {
    seekBar.setOnSeekBarChangeListener(this)
    seekBar.max = 255
    seekBar.progress = 255
  }

  /**
   * Sets UI Values
   *
   * @param savedValue Saved Color Value
   */
  private fun setUIValues(savedValue: String) {
    inputLayout.hint = "Enter custom HEX code"
    inputLayout.prefixText = "#"
    editText.filters = arrayOf<InputFilter>(LengthFilter(8))
    aEdittext.filters = arrayOf<InputFilter>(LengthFilter(3))
    rEdittext.filters = arrayOf<InputFilter>(LengthFilter(3))
    gEdittext.filters = arrayOf<InputFilter>(LengthFilter(3))
    bEdittext.filters = arrayOf<InputFilter>(LengthFilter(3))
    if (savedValue.isNotEmpty()) {
      colorPreview.color = Color.parseColor(savedValue)
      aEdittext.setText(Color.alpha(colorPreview.color).toString())
      aEdittext.setTextColor(colorPreview.invertedRGB)
      rEdittext.setText(Color.red(colorPreview.color).toString())
      rEdittext.setTextColor(colorPreview.invertedRGB)
      gEdittext.setText(Color.green(colorPreview.color).toString())
      gEdittext.setTextColor(colorPreview.invertedRGB)
      bEdittext.setText(Color.blue(colorPreview.color).toString())
      bEdittext.setTextColor(colorPreview.invertedRGB)
      updateARGB(colorPreview.color)
      updateSeekbars(colorPreview.color)
      updateEditText()
    }
  }

  /** Sets TextWatcher on EditText  */
  private fun setTextWatcherOnEditText() {
    editText.addTextChangedListener(
      object : TextWatcher {
        override fun beforeTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {}

        override fun onTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {}

        override fun afterTextChanged(p1: Editable) {
          if (editText.text.toString().isNotEmpty()) checkHexErrors(editText.text.toString())
        }
      })
    aEdittext.addTextChangedListener(
      object : TextWatcher {
        override fun beforeTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {}

        override fun onTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {
          checkAlphaErrors(p1.toString())
        }

        override fun afterTextChanged(p1: Editable) {}
      })
    rEdittext.addTextChangedListener(
      object : TextWatcher {
        override fun beforeTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {}

        override fun onTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {
          checkRedErrors(p1.toString())
        }

        override fun afterTextChanged(p1: Editable) {}
      })
    gEdittext.addTextChangedListener(
      object : TextWatcher {
        override fun beforeTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {}

        override fun onTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {
          checkGreenErrors(p1.toString())
        }

        override fun afterTextChanged(p1: Editable) {}
      })
    bEdittext.addTextChangedListener(
      object : TextWatcher {
        override fun beforeTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {}

        override fun onTextChanged(p1: CharSequence, p2: Int, p3: Int, p4: Int) {
          checkBlueErrors(p1.toString())
        }

        override fun afterTextChanged(p1: Editable) {}
      })
  }

  /** Called when Save button is clicked  */
  public override fun onClickSave() {
    listener.onSave("#" + colorPreview.hexColor)
  }

  /**
   * Checks for Alpha Errors
   *
   * @param alpha user entered Alpha value
   */
  private fun checkAlphaErrors(alpha: String) {
    if (alpha.isNotEmpty() && Pattern.matches("[0-9]*", alpha)) {
      aInputLayout.isErrorEnabled = false
      aInputLayout.error = ""
      setPositiveButtonEnabled(true)
      if (alpha.toInt() != Color.alpha(colorPreview.color)) {
        colorPreview.setAlpha(alpha.toInt())
        updateSeekbars(colorPreview.color)
        updateEditText()
      }
      return
    }
    aInputLayout.isErrorEnabled = true
    aInputLayout.error = "Invalid Alpha value"
    setPositiveButtonEnabled(false)
  }

  /**
   * Checks for Red Errors
   *
   * @param red user entered RED value
   */
  private fun checkRedErrors(red: String) {
    if (red.isNotEmpty() && Pattern.matches("[0-9]*", red)) {
      rInputLayout.isErrorEnabled = false
      rInputLayout.error = ""
      setPositiveButtonEnabled(true)
      if (red.toInt() != Color.alpha(colorPreview.color)) {
        colorPreview.setRed(red.toInt())
        updateSeekbars(colorPreview.color)
        updateEditText()
      }
      return
    }
    rInputLayout.isErrorEnabled = true
    rInputLayout.error = "Invalid Red value"
    setPositiveButtonEnabled(false)
  }

  /**
   * Checks for Green Errors
   *
   * @param green user entered GREEN value
   */
  private fun checkGreenErrors(green: String) {
    if (green.isNotEmpty() && Pattern.matches("[0-9]*", green)) {
      gInputLayout.isErrorEnabled = false
      gInputLayout.error = ""
      setPositiveButtonEnabled(true)
      if (green.toInt() != Color.alpha(colorPreview.color)) {
        colorPreview.setGreen(green.toInt())
        updateSeekbars(colorPreview.color)
        updateEditText()
      }
      return
    }
    gInputLayout.isErrorEnabled = true
    gInputLayout.error = "Invalid Green value"
    setPositiveButtonEnabled(false)
  }

  /**
   * Checks for Blue Errors
   *
   * @param blue user entered BLUE value
   */
  private fun checkBlueErrors(blue: String) {
    if (blue.isNotEmpty() && Pattern.matches("[0-9]*", blue)) {
      bInputLayout.isErrorEnabled = false
      bInputLayout.error = ""
      setPositiveButtonEnabled(true)
      if (blue.toInt() != Color.alpha(colorPreview.color)) {
        colorPreview.setBlue(blue.toInt())
        updateSeekbars(colorPreview.color)
        updateEditText()
      }
      return
    }
    bInputLayout.isErrorEnabled = true
    bInputLayout.error = "Invalid Blue value"
    setPositiveButtonEnabled(false)
  }

  /**
   * Checks for Hex Errors
   *
   * @param hex user entered HEX value
   */
  private fun checkHexErrors(hex: String) {
    if (Pattern.matches("[a-fA-F0-9]{6}", hex) || Pattern.matches("[a-fA-F0-9]{8}", hex)) {
      colorPreview.color = Color.parseColor("#$hex")
      updateSeekbars(colorPreview.color)
      updateARGB(colorPreview.color)
      inputLayout.isErrorEnabled = false
      inputLayout.error = ""
      setPositiveButtonEnabled(true)
      return
    }
    inputLayout.isErrorEnabled = true
    inputLayout.error = "Invalid HEX value"
    setPositiveButtonEnabled(false)
  }

  /**
   * Updates ARGB with Color Values
   *
   * @param color Color to be set
   */
  private fun updateARGB(color: Int) {
    val a = Color.alpha(color)
    val r = Color.red(color)
    val g = Color.green(color)
    val b = Color.blue(color)

    if (a != (if (aEdittext.text.toString().isEmpty()) 0 else aEdittext.text.toString().toInt())) {
      aEdittext.setText(a.toString())
    }

    if (r != (if (rEdittext.text.toString().isEmpty()) 0 else rEdittext.text.toString().toInt())) {
      rEdittext.setText(r.toString())
    }

    if (g != (if (gEdittext.text.toString().isEmpty()) 0 else gEdittext.text.toString().toInt())) {
      gEdittext.setText(g.toString())
    }

    if (b != (if (bEdittext.text.toString().isEmpty()) 0 else bEdittext.text.toString().toInt())) {
      bEdittext.setText(b.toString())
    }

    aEdittext.setTextColor(colorPreview.invertedRGB)
    rEdittext.setTextColor(colorPreview.invertedRGB)
    gEdittext.setTextColor(colorPreview.invertedRGB)
    bEdittext.setTextColor(colorPreview.invertedRGB)
  }

  /**
   * Updates Seekbars with Color Values
   *
   * @param color Color to be set
   */
  private fun updateSeekbars(color: Int) {
    val a = Color.alpha(color)
    val r = Color.red(color)
    val g = Color.green(color)
    val b = Color.blue(color)
    seekAlpha.progress = a
    seekRed.progress = r
    seekGreen.progress = g
    seekBlue.progress = b
  }

  /** Updates EditText with Color Values  */
  private fun updateEditText() {
    editText.setText(colorPreview.hexColor)
  }

  /**
   * Called when Seekbar progress is changed
   *
   * @param seek Seekbar which is changed
   * @param progress Progress of Seekbar
   * @param fromUser True if changed by user
   */
  @SuppressLint("NonConstantResourceId")
  override fun onProgressChanged(seek: SeekBar, progress: Int, fromUser: Boolean) {
    if (fromUser) {
      val id = seek.id
      if (id == R.id.seek_alpha) {
        colorPreview.setAlpha(progress)
        updateARGB(colorPreview.color)
        updateEditText()
      } else if (id == R.id.seek_red) {
        colorPreview.setRed(progress)
        updateARGB(colorPreview.color)
        updateEditText()
      } else if (id == R.id.seek_green) {
        colorPreview.setGreen(progress)
        updateARGB(colorPreview.color)
        updateEditText()
      } else if (id == R.id.seek_blue) {
        colorPreview.setBlue(progress)
        updateARGB(colorPreview.color)
        updateEditText()
      }
    }
  }

  override fun onStartTrackingTouch(p1: SeekBar) {}

  override fun onStopTrackingTouch(p1: SeekBar) {}
}