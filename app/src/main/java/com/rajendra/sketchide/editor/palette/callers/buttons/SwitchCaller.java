package com.rajendra.sketchide.editor.palette.callers.buttons;

import android.content.Context;
import android.view.View;
import android.widget.Switch;

import androidx.appcompat.widget.SwitchCompat;

public class SwitchCaller {
  public static void setChecked(View target, String value, Context context) {
    if (value.equals("true")) {
      if (target instanceof Switch) ((Switch) target).setChecked(true);
      else if (target instanceof SwitchCompat) ((SwitchCompat) target).setChecked(true);
    } else {
      if (target instanceof Switch) ((Switch) target).setChecked(false);
      else if (target instanceof SwitchCompat) ((SwitchCompat) target).setChecked(false);
    }
  }
}
