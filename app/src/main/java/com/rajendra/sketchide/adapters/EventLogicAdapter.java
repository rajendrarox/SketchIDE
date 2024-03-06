package com.rajendra.sketchide.adapters;
import static com.rajendra.sketchide.adapters.EventLogicAdapter.*;
import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.rajendra.sketchide.R;
import com.rajendra.sketchide.activities.BackendBlockProgram;
import com.rajendra.sketchide.activities.EditorActivity;
import com.rajendra.sketchide.models.LogicModel;
import java.util.ArrayList;

public class EventLogicAdapter extends RecyclerView.Adapter<ViewHolder> {

    private final Context context;
    private final ArrayList<LogicModel> arrLogicModel;

    public EventLogicAdapter(Context context, ArrayList<LogicModel> arrLogicModel) {
        this.context = context;
        this.arrLogicModel = arrLogicModel;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.layout_logic_item, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        LogicModel Logic = arrLogicModel.get(position);
        holder.activityTitle.setText(Logic.ActivityTitle);
        holder.activityEventType.setText(Logic.ActivityEventType);


        // Long-press listener for RecyclerView items
        holder.LayoutLogicItem.setOnLongClickListener(v -> {
            Toast.makeText(v.getContext(), "Long Logic Click event Soon", Toast.LENGTH_LONG).show();

            return true;
        });

        // Click listener for RecyclerView items / logic Event click open Activity
        holder.LayoutLogicItem.setOnClickListener(v -> {
            Intent intentBackendBlockProgram = new Intent(context, BackendBlockProgram.class);
            context.startActivity(intentBackendBlockProgram);

        });

    }

    @Override
    public int getItemCount() {
        return arrLogicModel.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {

        TextView activityTitle, activityEventType;
        LinearLayout LayoutLogicItem;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            activityTitle = itemView.findViewById(R.id.txt_logic_title);
            activityEventType = itemView.findViewById(R.id.txt_logic_event_type);
            LayoutLogicItem = itemView.findViewById(R.id.layout_logic_item);
        }
    }
}

