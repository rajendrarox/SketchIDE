package com.rajendra.sketchide.editor

import android.animation.LayoutTransition
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.DashPathEffect
import android.graphics.Paint
import android.util.AttributeSet
import android.view.DragEvent
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.LinearLayout
import android.widget.Toast
import androidx.appcompat.widget.TooltipCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.blankj.utilcode.util.SizeUtils
import com.google.android.material.R.attr
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.color.MaterialColors
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.rajendra.sketchide.R
import com.rajendra.sketchide.adapters.AppliedAttributesAdapter
import com.rajendra.sketchide.databinding.ShowAttributesDialogBinding
import com.rajendra.sketchide.editor.dialogs.AttributeDialog
import com.rajendra.sketchide.editor.dialogs.BooleanDialog
import com.rajendra.sketchide.editor.dialogs.ColorDialog
import com.rajendra.sketchide.editor.dialogs.EnumDialog
import com.rajendra.sketchide.editor.dialogs.FlagDialog
import com.rajendra.sketchide.editor.dialogs.NumberDialog
import com.rajendra.sketchide.editor.dialogs.SizeDialog
import com.rajendra.sketchide.editor.dialogs.StringDialog
import com.rajendra.sketchide.editor.dialogs.interfaces.OnSaveValueListener
import com.rajendra.sketchide.managers.IdManager
import com.rajendra.sketchide.managers.UndoRedoManager
import com.rajendra.sketchide.utils.ArgumentUtil
import com.rajendra.sketchide.utils.Constants
import com.rajendra.sketchide.utils.FileUtils
import com.rajendra.sketchide.utils.InvokeUtils
import com.rajendra.sketchide.utils.parser.XmlLayoutGenerator
import com.rajendra.sketchide.utils.parser.XmlLayoutParser
import kotlin.math.abs

@Suppress("UNCHECKED_CAST")
class EditorLayout @JvmOverloads constructor(
  context: Context, attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

  private val paint = Paint()
  private val shadow = View(context)
  private var isBlueprint = false

  private val attributes: HashMap<String, List<HashMap<String, Any>>>
  private val parentAttributes: HashMap<String, List<HashMap<String, Any>>>
  private var initializer: AttributeInitializer

  var viewAttributeMap: HashMap<View, AttributeMap>
    private set

  var undoRedoManager: UndoRedoManager? = null

  init {
    shadow.apply {
      layoutParams = LayoutParams(SizeUtils.dp2px(80f), SizeUtils.dp2px(40f))
      setBackgroundColor(MaterialColors.getColor(this@EditorLayout, attr.colorOutline))
    }
    paint.strokeWidth = SizeUtils.dp2px(3f).toFloat()
    orientation = VERTICAL

    applyTransition(this)
    applyDragListener()

    attributes = convertJsonToObjects(Constants.ATTRIBUTES_FILE_NAME)
    parentAttributes = convertJsonToObjects(Constants.PARENT_ATTRS_FILE_NAME)
    viewAttributeMap = HashMap()
    initializer = AttributeInitializer(context, viewAttributeMap, attributes, parentAttributes)

    setBlueprintOnChildren()
    setStrokeEnabledOnChildren()
  }

  override fun dispatchDraw(canvas: Canvas) {
    super.dispatchDraw(canvas)
    paint.apply {
      color = Constants.DESIGN_BORDER_COLOR
      isAntiAlias = true
      style = Paint.Style.STROKE
      pathEffect = DashPathEffect(floatArrayOf(10f, 7f), 0f)
    }
    canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paint)
  }

  private fun setStrokeEnabledOnChildren() {
    try {
      for (view in viewAttributeMap.keys) {
        val cls = view.javaClass
        val setStrokeEnabled = cls.getMethod("setStrokeEnabled", Boolean::class.javaPrimitiveType)
        setStrokeEnabled(cls, true)
      }
    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  private fun setBlueprintOnChildren() {
    try {
      for (view in viewAttributeMap.keys) {
        val cls = view.javaClass
        val setBlueprint = cls.getMethod("setBlueprint", Boolean::class.javaPrimitiveType)
        setBlueprint(cls, isBlueprint)
      }
    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  fun loadLayoutFromXml(xml: String) {
    clearAll()
    if (xml.isEmpty()) return

    val parser = XmlLayoutParser(context, xml)
    addView(parser.root)
    viewAttributeMap = parser.viewAttributeMap

    for (view in viewAttributeMap.keys) {
      view.rearrangeListeners()
      if (view is ViewGroup) {
        applyTransition(view)
        view.applyDragListener()
      }

      view.apply {
        minimumWidth = SizeUtils.dp2px(20f)
        minimumHeight = SizeUtils.dp2px(20f)
      }
    }

    // update structure
    setStrokeEnabledOnChildren()

    initializer = AttributeInitializer(context, viewAttributeMap, attributes, parentAttributes)
  }

  fun undo() {
    if (undoRedoManager != null) {
      if (undoRedoManager!!.isUndoEnabled) {
        loadLayoutFromXml(undoRedoManager!!.undo())
      }
    }
  }

  fun redo() {
    if (undoRedoManager != null) {
      if (undoRedoManager!!.isRedoEnabled) {
        loadLayoutFromXml(undoRedoManager!!.redo())
      }
    }
  }

  fun updateUndoRedoHistory() {
    if (undoRedoManager == null) return
    val result = XmlLayoutGenerator().generate(this, false)
    undoRedoManager!!.addToHistory(result)
  }

  private fun applyTransition(viewGroup: ViewGroup) {
    if (viewGroup is RecyclerView) return
    LayoutTransition().apply {
      disableTransitionType(LayoutTransition.CHANGE_DISAPPEARING)
      enableTransitionType(LayoutTransition.CHANGING)
      setDuration(150)
    }.also { viewGroup.layoutTransition = it }
  }

  private fun clearAll() {
    removeAllViews()
    // clear structure view
    viewAttributeMap.clear()
  }

  private fun addWidget(view: View, newParent: ViewGroup, event: DragEvent) {
    removeWidget(view)
    if (newParent is LinearLayout) {
      newParent.addView(view, newParent.getIndexForNewChild(event))
    } else {
      try {
        newParent.addView(view, newParent.childCount)
      } catch (e: Exception) {
        e.printStackTrace()
      }
    }
  }

  private fun removeWidget(view: View) {
    (view.parent as ViewGroup?)?.removeView(view)
  }

  private fun removeViewAttributes(view: View) {
    viewAttributeMap.remove(view)
    if (view is ViewGroup) {
      for (i in 0 until view.childCount) {
        removeViewAttributes(view.getChildAt(i))
      }
    }
  }

  private fun removeAttribute(view: View, attributeKey: String): View {
    var target = view

    val allAttrs = initializer.getAllAttributesForView(target)
    val currentAttr = initializer.getAttributeFromKey(attributeKey, allAttrs)
    val attributeMap = viewAttributeMap[target]

    if (currentAttr.containsKey(Constants.KEY_CAN_DELETE)) return target

    val name = if (attributeMap!!.containsKey("android:id")) attributeMap["android:id"] else null
    val id = if (name != null) IdManager.getViewId(name.replace("@+id/", "")) else -1

    attributeMap.remove(attributeKey)

    if (attributeKey == "android:id") {
      IdManager.removeId(target, false)
      target.id = -1
      target.requestLayout()

      for (mView in viewAttributeMap.keys) {
        val attrMap = viewAttributeMap[mView]

        for (key in attrMap!!.keySet()) {
          val value = attrMap[key]!!
          if (value.startsWith("@+id/") && (value == name!!.replace("+", ""))) {
            attrMap.remove(key)
          }
        }
      }
      // update structure
      return target
    }

    viewAttributeMap.remove(target)

    val parent = target.parent as ViewGroup
    val indexOfView = parent.indexOfChild(target)
    parent.removeView(target)

    val childs = mutableListOf<View>()

    if (target is ViewGroup) {
      if (target.childCount > 0) {
        for (i in 0 until target.childCount) {
          val child = target.getChildAt(i)
          childs.add(child)
        }
      }
      target.removeAllViews()
    }

    if (name != null) IdManager.removeId(target, false)

    target = InvokeUtils.createView(target.javaClass.name, context)
    target.rearrangeListeners()

    if (target is ViewGroup) {
      target.apply {
        minimumWidth = SizeUtils.dp2px(20f)
        minimumHeight = SizeUtils.dp2px(20f)
      }

      val group = target

      if (childs.size > 0) {
        for (child in childs) {
          group.addView(child)
        }
      }
      applyTransition(group)
    }

    parent.addView(target, indexOfView)
    viewAttributeMap[target] = attributeMap

    if (name != null) {
      IdManager.addId(target, name, id)
      target.requestLayout()
    }

    val keys = attributeMap.keySet()
    val values = attributeMap.values()
    val attrs = mutableListOf<HashMap<String, Any>>()

    for (key in keys) {
      for (map in allAttrs) {
        if (map[Constants.KEY_ATTRIBUTE_NAME] == key) {
          attrs.add(map)
          break
        }
      }
    }

    for (i in keys.indices) {
      val key = keys[i]
      if (key == "android:id") continue
      initializer.applyAttributes(target, values[i], attrs[i])
    }

    try {
      val cls = target.javaClass
      val setStrokeEnabled = cls.getMethod("setStrokeEnabled", Boolean::class.javaPrimitiveType)
      setStrokeEnabled(target, true)
    } catch (e: Exception) {
      e.printStackTrace()
    }
    // update structure
    updateUndoRedoHistory()

    return target
  }

  private fun convertJsonToObjects(jsonFilePath: String): HashMap<String, List<HashMap<String, Any>>> {
    return Gson()
      .fromJson(
        FileUtils.readFromAssets(context, jsonFilePath),
        object : TypeToken<HashMap<String, List<HashMap<String, Any>>>>() {}.type
      )
  }

  private fun showDefinedAttributes(view: View) {
    val keys = viewAttributeMap[view]!!.keySet()
    val values = viewAttributeMap[view]!!.values()

    val attrs = mutableListOf<HashMap<String, Any>>()
    val allAttrs = initializer.getAllAttributesForView(view)

    val dialog = BottomSheetDialog(context)
    val binding = ShowAttributesDialogBinding.inflate(dialog.layoutInflater)

    dialog.setContentView(binding.root)
    TooltipCompat.setTooltipText(binding.btnAdd, "Add attribute")
    TooltipCompat.setTooltipText(binding.btnDelete, "Delete")

    for (key in keys) {
      for (map in allAttrs) {
        if (map[Constants.KEY_ATTRIBUTE_NAME] == key) {
          attrs.add(map)
          break
        }
      }
    }

    val appliedAttributesAdapter = AppliedAttributesAdapter(attrs, values)

    appliedAttributesAdapter.onClick = {
      showAttributeEdit(view, keys[it])
      dialog.dismiss()
    }

    appliedAttributesAdapter.onRemoveButtonClick = {
      dialog.dismiss()

      val mView = removeAttribute(view, keys[it])
      showDefinedAttributes(mView)
    }

    binding.apply {
      attributesList.apply {
        adapter = appliedAttributesAdapter
        layoutManager = LinearLayoutManager(context, RecyclerView.VERTICAL, false)
      }

      viewName.text = view.javaClass.superclass.simpleName
      viewFullName.text = view.javaClass.superclass.name

      btnAdd.setOnClickListener {
        showAvailableAttributes(view)
        dialog.dismiss()
      }

      btnDelete.setOnClickListener {
        MaterialAlertDialogBuilder(context)
          .setTitle(R.string.delete_view)
          .setMessage(R.string.msg_delete_view)
          .setNegativeButton(R.string.no) { d, _ -> d.dismiss() }
          .setPositiveButton(R.string.yes) { _, _ ->
            IdManager.removeId(view, view is ViewGroup)
            removeViewAttributes(view)
            removeWidget(view)
            // update structure
            updateUndoRedoHistory()
            dialog.dismiss()
          }
          .show()
      }
    }

    dialog.show()
  }

  private fun showAvailableAttributes(view: View) {
    val availableAttrs = initializer.getAvailableAttributesForView(view)
    val names = mutableListOf<String>()

    for (attr in availableAttrs) {
      names.add(attr["name"].toString())
    }

    MaterialAlertDialogBuilder(context)
      .setTitle("Available attributes")
      .setAdapter(ArrayAdapter(context, android.R.layout.simple_list_item_1, names)) { _, w ->
        showAttributeEdit(view, availableAttrs[w][Constants.KEY_ATTRIBUTE_NAME].toString())
      }
      .show()
  }

  private fun showAttributeEdit(view: View, attributeKey: String) {
    val allAttrs = initializer.getAllAttributesForView(view)
    val currentAttr = initializer.getAttributeFromKey(attributeKey, allAttrs)
    val attributeMap = viewAttributeMap[view]

    val argumentTypes = currentAttr[Constants.KEY_ARGUMENT_TYPE].toString().split("\\|".toRegex())
      .dropLastWhile { it.isEmpty() }.toTypedArray()

    if (argumentTypes.size > 1) {
      if (attributeMap!!.containsKey(attributeKey)) {
        val argumentType = ArgumentUtil.parseType(attributeMap[attributeKey], argumentTypes)
        showAttributeEdit(view, attributeKey, argumentType)
        return
      }
      MaterialAlertDialogBuilder(context)
        .setTitle(R.string.select_arg_type)
        .setAdapter(ArrayAdapter(context, android.R.layout.simple_list_item_1, argumentTypes)) { _, w ->
          showAttributeEdit(view, attributeKey, argumentTypes[w])
        }
        .show()
    }
    showAttributeEdit(view, attributeKey, argumentTypes[0])
  }

  private fun showAttributeEdit(view: View, attributeKey: String, argumentType: String) {
    val allAttrs = initializer.getAllAttributesForView(view)
    val currentAttr = initializer.getAttributeFromKey(attributeKey, allAttrs)
    val attributeMap = viewAttributeMap[view]

    val savedValue = if (attributeMap!!.containsKey(attributeKey)) attributeMap[attributeKey] else ""
    val defaultValue = if (currentAttr.containsKey(Constants.KEY_DEFAULT_VALUE)) currentAttr[Constants.KEY_DEFAULT_VALUE].toString() else null
    val constant = if (currentAttr.containsKey(Constants.KEY_CONSTANT)) currentAttr[Constants.KEY_CONSTANT].toString() else null

    var dialog: AttributeDialog? = null

    when (argumentType) {
      Constants.ARGUMENT_TYPE_SIZE -> dialog = SizeDialog(context, savedValue ?: "")
      Constants.ARGUMENT_TYPE_COLOR -> dialog = ColorDialog(context, savedValue ?: "")
      Constants.ARGUMENT_TYPE_BOOLEAN -> dialog = BooleanDialog(context, savedValue ?: "")
      Constants.ARGUMENT_TYPE_STRING -> dialog = StringDialog(context, savedValue ?: "", Constants.ARGUMENT_TYPE_STRING)
      Constants.ARGUMENT_TYPE_TEXT -> dialog = StringDialog(context, savedValue ?: "", Constants.ARGUMENT_TYPE_TEXT)
      Constants.ARGUMENT_TYPE_INT -> dialog = NumberDialog(context, savedValue ?: "", Constants.ARGUMENT_TYPE_INT)
      Constants.ARGUMENT_TYPE_FLOAT -> dialog = NumberDialog(context, savedValue ?: "", Constants.ARGUMENT_TYPE_FLOAT)
      Constants.ARGUMENT_TYPE_FLAG -> dialog = FlagDialog(context, savedValue ?: "", currentAttr["arguments"] as ArrayList<String>)
      Constants.ARGUMENT_TYPE_ENUM -> dialog = EnumDialog(context, savedValue ?: "", currentAttr["arguments"] as ArrayList<String>)
    }
    if (dialog == null) return

    dialog.apply {
      setTitle(currentAttr["name"].toString())
      setOnSaveValueListener {
        if (defaultValue != null && defaultValue == it) {
          if (attributeMap.containsKey(attributeKey)) removeAttribute(view, attributeKey)
        } else {
          initializer.applyAttributes(view, it!!, currentAttr)
          showDefinedAttributes(view)
          updateUndoRedoHistory()
          // update structure
        }
      }
    }

    dialog.show()
  }

  @SuppressLint("ClickableViewAccessibility")
  private fun View.rearrangeListeners() {
    val gestureDetector = GestureDetector(
      context,
      object : GestureDetector.SimpleOnGestureListener() {
        override fun onLongPress(e: MotionEvent) {
          this@rearrangeListeners.startDragAndDrop(
            null,
            DragShadowBuilder(this@rearrangeListeners),
            this@rearrangeListeners,
            0
          )
        }

        override fun onSingleTapConfirmed(e: MotionEvent): Boolean {
          showDefinedAttributes(this@rearrangeListeners)
          return true
        }
      }
    )

    setOnTouchListener { _, event ->
      gestureDetector.onTouchEvent(event)
      true
    }
  }

  private fun ViewGroup.applyDragListener() {
    setOnDragListener { v, event ->
      var parent = v as ViewGroup
      val draggedView = event.localState as? View

      when (event.action) {
        DragEvent.ACTION_DRAG_STARTED -> {
          if (draggedView != null && !(draggedView is AdapterView<*> && parent is AdapterView<*>)) {
            parent.removeView(draggedView)
          }
        }

        DragEvent.ACTION_DRAG_EXITED -> {
          removeWidget(shadow)
          updateUndoRedoHistory()
        }

        DragEvent.ACTION_DRAG_ENDED -> {
          if (!event.result && draggedView != null) {
            IdManager.removeId(draggedView, draggedView is ViewGroup)
            removeViewAttributes(draggedView)
            viewAttributeMap.remove(draggedView)
            // update structure
          }
        }

        DragEvent.ACTION_DRAG_LOCATION, DragEvent.ACTION_DRAG_ENTERED -> {
          if (shadow.parent == null) {
            addWidget(shadow, parent, event)
          } else {
            if (parent is LinearLayout) {
              val index = parent.indexOfChild(shadow)
              val newIndex = parent.getIndexForNewChild(event)

              if (index != newIndex) {
                parent.removeView(shadow)
                parent.addView(shadow, newIndex)
              }
            } else {
              if (shadow !== parent) addWidget(shadow, parent, event)
            }
          }
        }

        DragEvent.ACTION_DROP -> {
          removeWidget(shadow)
          if (childCount >= 1) {
            if (getChildAt(0) !is ViewGroup) {
              Toast.makeText(
                context,
                "Can't add more than one widget in the editor.",
                Toast.LENGTH_SHORT
              ).show()
              return@setOnDragListener true
            } else {
              if (parent is EditorLayout) parent = getChildAt(0) as ViewGroup
            }
          }

          if (draggedView == null) {
            val data = event.localState as HashMap<String, Any>
            val newView = InvokeUtils.createView(data[Constants.KEY_CLASS_NAME].toString(), context)
            newView.apply {
              layoutParams = LayoutParams(
                LayoutParams.WRAP_CONTENT,
                LayoutParams.WRAP_CONTENT
              )
              rearrangeListeners()
              minimumWidth = SizeUtils.dp2px(20f)
              minimumHeight = SizeUtils.dp2px(20f)
            }

            if (newView is ViewGroup) {
              newView.applyDragListener()
              applyTransition(newView)
            }

            val map = AttributeMap()
            map.put("android:layout_width", "wrap_content")
            map.put("android:layout_height", "wrap_content")
            viewAttributeMap[newView] = map

            addWidget(newView, parent, event)

            try {
              val cls = newView.javaClass
              val setStrokeEnabled =
                cls.getMethod("setStrokeEnabled", Boolean::class.javaPrimitiveType)
              val setBlueprint = cls.getMethod("setBlueprint", Boolean::class.javaPrimitiveType)
              setStrokeEnabled(newView, true)
              setBlueprint(newView, false)
            } catch (e: Exception) {
              e.printStackTrace()
            }

            if (data.containsKey(Constants.KEY_DEFAULT_ATTRS)) {
              @Suppress("UNCHECKED_CAST")
              initializer.applyDefaultAttributes(
                newView,
                data[Constants.KEY_DEFAULT_ATTRS] as MutableMap<String, String>
              )
            }
          } else {
            addWidget(draggedView, parent, event)
          }
          // update structure
          updateUndoRedoHistory()
        }
      }
      true
    }
  }

  private fun LinearLayout.getIndexForNewChild(event: DragEvent): Int {
    val orientation = this.orientation
    if (orientation == HORIZONTAL) {
      var index = 0
      for (i in 0 until childCount) {
        val child = getChildAt(i)
        if (child === shadow) continue
        if (child.right < event.x) index++
      }
      return index
    }
    if (orientation == VERTICAL) {
      var index = 0
      for (i in 0 until childCount) {
        val child = getChildAt(i)
        if (child === shadow) continue
        if (child.bottom < event.y) index++
      }
      return index
    }
    return -1
  }
}
