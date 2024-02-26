package com.rajendra.sketchide.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.widget.TooltipCompat
import androidx.recyclerview.widget.RecyclerView
import com.rajendra.sketchide.databinding.ShowAttributeItemBinding
import com.rajendra.sketchide.utils.Constants

class AppliedAttributesAdapter(
  private val attrs: List<HashMap<String, Any>>,
  private val values: List<String>
) : RecyclerView.Adapter<AppliedAttributesAdapter.ViewHolder>() {

  var onClick: (Int) -> Unit = {}
  var onRemoveButtonClick: (Int) -> Unit = {}

  inner class ViewHolder(val binding: ShowAttributeItemBinding) : RecyclerView.ViewHolder(binding.root)

  override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
    return ViewHolder(ShowAttributeItemBinding.inflate(LayoutInflater.from(parent.context), parent, false))
  }

  override fun getItemCount(): Int {
    return attrs.size
  }

  override fun onBindViewHolder(holder: ViewHolder, position: Int) {
    val binding = holder.binding

    binding.apply {
      attributeName.text = attrs[position]["name"].toString()
      attributeValue.text = values[position]

      TooltipCompat.setTooltipText(btnRemoveAttribute, "Remove")
      TooltipCompat.setTooltipText(root, attrs[position]["name"].toString())

      if (attrs[position].containsKey(Constants.KEY_CAN_DELETE)) {
        btnRemoveAttribute.visibility = View.GONE
      }

      root.setOnClickListener { onClick(position) }
      btnRemoveAttribute.setOnClickListener { onRemoveButtonClick(position) }
    }
  }
}