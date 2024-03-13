package com.rajendra.sketchide.editor.palette.callers.buttons;

import android.content.Context;
import android.view.View;
import android.widget.CheckBox;

public class CheckBoxCaller {
  public static void setChecked(View target, String value, Context context) {
    if (target instanceof CheckBox) ((CheckBox) target).setChecked(Boolean.parseBoolean(value));
  }
}
