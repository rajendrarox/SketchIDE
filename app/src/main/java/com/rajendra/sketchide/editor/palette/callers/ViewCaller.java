package com.rajendra.sketchide.editor.palette.callers;

import android.content.Context;
import android.view.View;

import com.rajendra.sketchide.managers.IdManager;
import com.rajendra.sketchide.utils.Constants;
import com.rajendra.sketchide.utils.DimensionUtil;

import java.util.Objects;

public class ViewCaller {
  public static void setId(View target, String value, Context context) {
    IdManager.addNewId(target, value);
  }

  public static void setLayoutWidth(View target, String value, Context context) {
    target.getLayoutParams().width = (int) DimensionUtil.parse(value, context);
    target.requestLayout();
  }

  public static void setLayoutHeight(View target, String value, Context context) {
    target.getLayoutParams().height = (int) DimensionUtil.parse(value, context);
    target.requestLayout();
  }

  public static void setElevation(View target, String value, Context context) {
    target.setElevation(DimensionUtil.parse(value, context));
  }

  public static void setAlpha(View target, String value, Context context) {
    target.setAlpha(Float.parseFloat(value));
  }

  public static void setRotation(View target, String value, Context context) {
    target.setRotation(Float.parseFloat(value));
  }

  public static void setRotationX(View target, String value, Context context) {
    target.setRotationX(Float.parseFloat(value));
  }

  public static void setRotationY(View target, String value, Context context) {
    target.setRotationY(Float.parseFloat(value));
  }

  public static void setTranslationX(View target, String value, Context context) {
    target.setTranslationX(DimensionUtil.parse(value, context));
  }

  public static void setTranslationY(View target, String value, Context context) {
    target.setTranslationY(DimensionUtil.parse(value, context));
  }

  public static void setTranslationZ(View target, String value, Context context) {
    target.setTranslationZ(DimensionUtil.parse(value, context));
  }

  public static void setScaleX(View target, String value, Context context) {
    target.setScaleX(Float.parseFloat(value));
  }

  public static void setScaleY(View target, String value, Context context) {
    target.setScaleY(Float.parseFloat(value));
  }

  public static void setPadding(View target, String value, Context context) {
    int pad = (int) DimensionUtil.parse(value, context);
    target.setPadding(pad, pad, pad, pad);
  }

  public static void setPaddingLeft(View target, String value, Context context) {
    int pad = (int) DimensionUtil.parse(value, context);
    target.setPadding(
      pad, target.getPaddingTop(), target.getPaddingRight(), target.getPaddingBottom());
  }

  public static void setPaddingRight(View target, String value, Context context) {
    int pad = (int) DimensionUtil.parse(value, context);
    target.setPadding(
      target.getPaddingLeft(), target.getPaddingTop(), pad, target.getPaddingBottom());
  }

  public static void setPaddingTop(View target, String value, Context context) {
    int pad = (int) DimensionUtil.parse(value, context);
    target.setPadding(
      target.getPaddingLeft(), pad, target.getPaddingRight(), target.getPaddingBottom());
  }

  public static void setPaddingBottom(View target, String value, Context context) {
    int pad = (int) DimensionUtil.parse(value, context);
    target.setPadding(
      target.getPaddingLeft(), target.getPaddingTop(), target.getPaddingRight(), pad);
  }

  public static void setEnabled(View target, String value, Context context) {
    target.setEnabled(value.equals("true"));
  }

  public static void setVisibility(View target, String value, Context context) {
    target.setVisibility(Objects.requireNonNull(Constants.visibilityMap.get(value)));
  }
}