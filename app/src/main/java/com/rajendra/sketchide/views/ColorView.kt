package com.rajendra.sketchide.views

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.View

class ColorView(context: Context?, attrs: AttributeSet?) :
  View(context, attrs) {
  /** Alpha, red, green, blue value of the color.  */
  private var a = 255
  private var r = 255
  private var g = 255
  private var b = 255

  /** Drawable object to draw transparent background.  */
  private val transparent: Drawable = AlphaPatternDrawable(16)

  /** Paint object to draw color bitmap.  */
  private val bitmapPaint: Paint? = null

  /** Paint object to draw color.  */
  private val colorPaint = Paint()

  init {
    colorPaint.setARGB(a, r, g, b)
  }

  /**
   * This is called during layout when the size of this view has changed.
   *
   * @param w Current width of this view.
   * @param h Current height of this view.
   * @param oldw Old width of this view.
   * @param oldh Old height of this view.
   */
  override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
    super.onSizeChanged(w, h, oldw, oldh)
    transparent.setBounds(0, 0, w, h)
  }

  /**
   * Called when the view should render its content.
   *
   * @param canvas the Canvas object on which the view will draw.
   */
  override fun onDraw(canvas: Canvas) {
    super.onDraw(canvas)
    transparent.draw(canvas)
    canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), colorPaint)
  }

  /**
   * Set the alpha value of the color.
   *
   * @param value The value of alpha.
   */
  fun setAlpha(value: Int) {
    a = value
    colorPaint.setARGB(a, r, g, b)
    invalidate()
  }

  /**
   * Set the red value of the color.
   *
   * @param value The value of red.
   */
  fun setRed(value: Int) {
    r = value
    colorPaint.setARGB(a, r, g, b)
    invalidate()
  }

  /**
   * Set the green value of the color.
   *
   * @param value The value of green.
   */
  fun setGreen(value: Int) {
    g = value
    colorPaint.setARGB(a, r, g, b)
    invalidate()
  }

  /**
   * Set the blue value of the color.
   *
   * @param value The value of blue.
   */
  fun setBlue(value: Int) {
    b = value
    colorPaint.setARGB(a, r, g, b)
    invalidate()
  }

  var color: Int
    /**
     * Get the color.
     *
     * @return The color, packed as ARGB in a 32-bit int.
     */
    get() = Color.argb(a, r, g, b)
    /**
     * Set the color of the rectangle.
     *
     * @param color The color, packed as ARGB in a 32-bit int.
     */
    set(color) {
      a = Color.alpha(color)
      r = Color.red(color)
      g = Color.green(color)
      b = Color.blue(color)

      colorPaint.setARGB(a, r, g, b)
      invalidate()
    }

  val invertedRGB: Int
    /**
     * Get the inverted rgb color.
     *
     * @return The inverted color, packed as RGB in a 32-bit int.
     */
    get() = 0xFFFFFF xor Color.rgb(r, g, b)

  val hexColor: String
    /**
     * Get the hex value of the color.
     *
     * @return The hex value of the color.
     */
    get() = getHex(Color.argb(a, r, g, b))

  /**
   * Get the hex value of the given color.
   *
   * @param c The color, packed as ARGB in a 32-bit int.
   * @return The hex value of the given color.
   */
  private fun getHex(c: Int): String {
    return String.format(
      "%02x%02x%02x%02x", Color.alpha(c), Color.red(c), Color.green(c), Color.blue(c)
    ).uppercase()
  }
}