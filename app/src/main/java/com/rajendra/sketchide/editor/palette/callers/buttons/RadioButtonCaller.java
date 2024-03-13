package com.rajendra.sketchide.editor.palette.callers.buttons;

import android.content.Context;
import android.view.View;
import android.widget.RadioButton;

public class RadioButtonCaller {
  public static void setChecked(View target, String value, Context context) {
    if (target instanceof RadioButton)
      ((RadioButton) target).setChecked(Boolean.parseBoolean(value));
  }
}
