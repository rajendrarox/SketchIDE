package com.rajendra.sketchide.adapters

import android.annotation.SuppressLint
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.animation.AnimationUtils
import androidx.core.view.ViewCompat
import androidx.drawerlayout.widget.DrawerLayout
import androidx.recyclerview.widget.RecyclerView
import com.rajendra.sketchide.databinding.LayoutPaletteItemBinding
import com.rajendra.sketchide.utils.InvokeUtils
import com.rajendra.sketchide.R

class PaletteListAdapter(
  private val drawerLayout: DrawerLayout
) : RecyclerView.Adapter<PaletteListAdapter.VH>() {

  private lateinit var tab: List<HashMap<String, Any>>

  inner class VH(val binding: LayoutPaletteItemBinding) : RecyclerView.ViewHolder(binding.root)

  override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
    return VH(LayoutPaletteItemBinding.inflate(LayoutInflater.from(parent.context), parent, false))
  }

  override fun getItemCount(): Int {
    return tab.size
  }

  override fun onBindViewHolder(holder: VH, position: Int) {
    val widgetItem = tab[position]
    val binding = holder.binding

    binding.apply {
      icon.setImageResource(InvokeUtils.getMipmapId(widgetItem["iconName"].toString()))
      name.text = widgetItem["name"].toString()
      className.text = InvokeUtils.getSuperClassName(widgetItem["className"].toString())

      root.setOnLongClickListener {
        if (
          ViewCompat.startDragAndDrop(it, null, View.DragShadowBuilder(it), widgetItem, 0)
        ) {
          drawerLayout.closeDrawers()
        }
        true
      }
      root.animation = AnimationUtils.loadAnimation(
        holder.itemView.context, R.anim.project_list_animation
      )
    }
  }

  @SuppressLint("NotifyDataSetChanged")
  fun submitPaletteList(tab: List<HashMap<String, Any>>) {
    this.tab = tab
    notifyDataSetChanged()
  }
}