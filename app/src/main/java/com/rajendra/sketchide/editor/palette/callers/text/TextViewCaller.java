package com.rajendra.sketchide.editor.palette.callers.text;

import android.content.Context;
import android.graphics.Color;
import android.view.View;
import android.widget.CheckedTextView;
import android.widget.TextView;

import com.rajendra.sketchide.utils.Constants;
import com.rajendra.sketchide.utils.DimensionUtil;

public class TextViewCaller {
  public static void setText(View target, String value, Context context) {
    ((TextView) target).setText(value);
  }

  public static void setTextSize(View target, String value, Context context) {
    ((TextView) target).setTextSize(DimensionUtil.parse(value, context));
  }

  public static void setTextColor(View target, String value, Context context) {
    ((TextView) target).setTextColor(Color.parseColor(value));
  }

  public static void setGravity(View target, String value, Context context) {
    String[] flags = value.split("\\|");
    int result = 0;

    for (String flag : flags) {
      result |= Constants.gravityMap.get(flag);
    }

    ((TextView) target).setGravity(result);
  }

  public static void setChecked(View target, String value, Context context) {
    if (target instanceof CheckedTextView) {
      if (value.equals("true")) ((CheckedTextView) target).setChecked(true);
      else if (value.equals("false")) ((CheckedTextView) target).setChecked(false);
    }
  }

  public static void setTextStyle(View target, String value, Context context) {
    ((TextView) target).setTypeface(null, Constants.textStyleMap.get(value));
  }
}
