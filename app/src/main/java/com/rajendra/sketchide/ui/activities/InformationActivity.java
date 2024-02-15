package com.rajendra.sketchide.ui.activities;

import com.rajendra.sketchide.common.utils.FileUtils;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.rajendra.sketchide.R;
import com.rajendra.sketchide.databinding.ActivityInformationBinding;
import com.rajendra.sketchide.ui.adapters.InformationListAdapter;

import org.json.JSONArray;
import org.json.JSONException;

import java.util.ArrayList;

public class InformationActivity extends AppCompatActivity {
  private ActivityInformationBinding binding;
  private ArrayList<Information> InformationList;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    binding = ActivityInformationBinding.inflate(getLayoutInflater());
    setContentView(binding.getRoot());

    binding.toolbar.setTitle(R.string.information);
    setSupportActionBar(binding.toolbar);
    getSupportActionBar().setDisplayHomeAsUpEnabled(true);
    getSupportActionBar().setHomeButtonEnabled(true);
    binding.toolbar.setNavigationOnClickListener(
            view -> {
              onBackPressed();
            });

    String InformationListFileText = FileUtils.readFileFromAssets(getAssets(), "InformationList.json");
    InformationList = new ArrayList<Information>();

    try {
      JSONArray arr = new JSONArray(InformationListFileText);
      for (int pos = 0; pos < arr.length(); ++pos) {
        if (arr.getJSONObject(pos).has("Name") && arr.getJSONObject(pos).has("Path")) {
          Information License = new Information();
          License.setInformationName(arr.getJSONObject(pos).getString("Name"));
          License.setInformationPath(arr.getJSONObject(pos).getString("Path"));
          InformationList.add(License);
        }
      }
    } catch (JSONException e) {
    }
    binding.list.setAdapter(new InformationListAdapter(InformationList, this));
    binding.list.setLayoutManager(new LinearLayoutManager(this));
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    binding = null;
  }

  public class Information {
    private String InformationName;
    private String InformationPath;

    public String getInformationName() {
      return this.InformationName;
    }

    public void setInformationName(String InformationName) {
      this.InformationName = InformationName;
    }

    public String getInformationPath() {
      return this.InformationPath;
    }

    public void setInformationPath(String InformationPath) {
      this.InformationPath = InformationPath;
    }
  }
}
