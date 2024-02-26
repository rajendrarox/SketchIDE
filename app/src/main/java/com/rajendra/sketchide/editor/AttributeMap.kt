package com.rajendra.sketchide.editor

class AttributeMap {
  private val attributes = mutableListOf<Attribute>()

  fun put(key: String, value: String) {
    if (containsKey(key)) {
      attributes.find { it.key == key }?.value = value
    } else {
      attributes.add(Attribute(key, value))
    }
  }

  operator fun get(key: String): String? {
    return attributes.find { it.key == key }?.value
  }

  fun remove(key: String) {
    attributes.removeIf { it.key == key }
  }

  fun keySet(): List<String> {
    return attributes.map { it.key }.toList()
  }

  fun values(): List<String> {
    return attributes.map { it.value }.toList()
  }

  fun containsKey(key: String): Boolean {
    return attributes.any { it.key == key }
  }

  fun getAttributeIndexFromKey(key: String): Int {
    return attributes.indexOfFirst { it.key == key }
  }

  private inner class Attribute(val key: String, var value: String)
}