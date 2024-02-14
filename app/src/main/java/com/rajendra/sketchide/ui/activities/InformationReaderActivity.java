package com.rajendra.sketchide.ui.activities;

import com.rajendra.sketchide.common.utils.FileUtils;
import android.os.Bundle;
import android.text.method.LinkMovementMethod;
import android.text.util.Linkify;

import androidx.appcompat.app.AppCompatActivity;

import com.rajendra.sketchide.R;
import com.rajendra.sketchide.databinding.ActivityInformationReaderBinding;

public class InformationReaderActivity extends AppCompatActivity {
  private ActivityInformationReaderBinding binding;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    binding = ActivityInformationReaderBinding.inflate(getLayoutInflater());
    // set content view to binding's root.
    setContentView(binding.getRoot());

    binding.toolbar.setTitle(R.string.information);
    setSupportActionBar(binding.toolbar);


    binding.InformationText.setAutoLinkMask(Linkify.WEB_URLS);
    binding.InformationText.setMovementMethod(LinkMovementMethod.getInstance());
    binding.InformationText.setText(
        FileUtils.readFileFromAssets(getAssets(), getIntent().getStringExtra("Path")));
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    binding = null;
  }
}
