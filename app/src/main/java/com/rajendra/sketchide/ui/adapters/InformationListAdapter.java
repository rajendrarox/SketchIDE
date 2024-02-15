package com.rajendra.sketchide.ui.adapters;

import android.app.Activity;
import android.content.Intent;
import android.view.View;
import android.view.ViewGroup;

import androidx.recyclerview.widget.RecyclerView;

import com.rajendra.sketchide.databinding.LayoutInformationListItemBinding;
import com.rajendra.sketchide.ui.activities.InformationActivity;
import com.rajendra.sketchide.ui.activities.InformationReaderActivity;

import java.util.ArrayList;

public class InformationListAdapter extends RecyclerView.Adapter<InformationListAdapter.ViewHolder> {

  private ArrayList<InformationActivity.Information> InformationList;
  private Activity activity;

  public InformationListAdapter(ArrayList<InformationActivity.Information> InformationList, Activity activity) {
    this.InformationList = InformationList;
    this.activity = activity;
  }

  @Override
  public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
    LayoutInformationListItemBinding item =
        LayoutInformationListItemBinding.inflate(activity.getLayoutInflater());
    View _v = item.getRoot();
    RecyclerView.LayoutParams _lp =
        new RecyclerView.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
    _v.setLayoutParams(_lp);
    return new ViewHolder(_v);
  }

  @Override
  public void onBindViewHolder(ViewHolder _holder, final int _position) {
    LayoutInformationListItemBinding binding = LayoutInformationListItemBinding.bind(_holder.itemView);
    binding.name.setText(InformationList.get(_position).getInformationName());
    binding.name.setOnClickListener(
        v -> {
          Intent InformationReader = new Intent();
          InformationReader.setClass(activity, InformationReaderActivity.class);
          InformationReader.putExtra("Path", InformationList.get(_position).getInformationPath());
          activity.startActivity(InformationReader);
        });
  }

  @Override
  public int getItemCount() {
    return InformationList.size();
  }

  public class ViewHolder extends RecyclerView.ViewHolder {
    public ViewHolder(View v) {
      super(v);
    }
  }
}
