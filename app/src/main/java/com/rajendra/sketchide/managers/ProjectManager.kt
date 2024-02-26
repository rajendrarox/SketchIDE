package com.rajendra.sketchide.managers

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.rajendra.sketchide.SketchIDE
import com.rajendra.sketchide.utils.Constants
import com.rajendra.sketchide.utils.FileUtils
import java.util.concurrent.CompletableFuture

class ProjectManager private constructor() {

  private val paletteList = mutableListOf<List<HashMap<String, Any>>>()

  init {
    CompletableFuture.runAsync { initPalette() }
  }

  fun getPalette(position: Int) = paletteList[position]

  private fun initPalette() {
    paletteList.clear()
//    paletteList.add(convertJsonToObject(Constants.PALETTE_COMMON))
    paletteList.add(convertJsonToObject(Constants.PALETTE_TEXT))
//    paletteList.add(convertJsonToObject(Constants.PALETTE_BUTTONS))
//    paletteList.add(convertJsonToObject(Constants.PALETTE_WIDGETS))
//    paletteList.add(convertJsonToObject(Constants.PALETTE_LAYOUTS))
//    paletteList.add(convertJsonToObject(Constants.PALETTE_CONTAINERS))
//    paletteList.add(convertJsonToObject(Constants.PALETTE_GOOGLE))
//    paletteList.add(convertJsonToObject(Constants.PALETTE_LEGACY))
  }

  private fun convertJsonToObject(filePath: String): List<HashMap<String, Any>> {
    return Gson()
      .fromJson(
        FileUtils.readFromAssets(SketchIDE.instance.applicationContext, filePath),
        object : TypeToken<List<HashMap<String, Any>>>() {}.type
      )
  }

  companion object {
    @JvmStatic
    val instance: ProjectManager by lazy { ProjectManager() }
  }
}