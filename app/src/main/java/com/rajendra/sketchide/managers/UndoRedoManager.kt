package com.rajendra.sketchide.managers

import android.view.MenuItem

class UndoRedoManager(
  private val btnUndo: MenuItem?,
  private val btnRedo: MenuItem?
) {
  private val maxSize = 20
  private val history = arrayListOf<String>()
  private var index = 0

  fun addToHistory(text: String) {
    if (matchLastHistory(text)) return
    history.add(text)
    if (history.size == maxSize) history.removeAt(0)
    index = history.lastIndex
    updateButtons()
  }

  fun undo(): String {
    if (index > 0) {
      index--
      updateButtons()
      return history[index]
    }
    return ""
  }

  fun redo(): String {
    if (index < history.lastIndex) {
      index++
      updateButtons()
      return history[index]
    }
    return ""
  }

  fun updateButtons() {
    if (btnRedo == null || btnUndo == null) return
    btnUndo.isEnabled = isUndoEnabled
    btnRedo.isEnabled = isRedoEnabled
    btnUndo.icon?.alpha = if (isUndoEnabled) 255 else 128
    btnRedo.icon?.alpha = if (isRedoEnabled) 255 else 128
  }

  val isUndoEnabled: Boolean
    get() = index > 0

  val isRedoEnabled: Boolean
    get() = index < history.lastIndex

  private fun matchLastHistory(text: String): Boolean {
    val lastIndex = history.lastIndex
    if (lastIndex < 0) return false
    return text === history[lastIndex]
  }
}