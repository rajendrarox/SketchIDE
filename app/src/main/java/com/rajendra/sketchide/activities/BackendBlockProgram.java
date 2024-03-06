package com.rajendra.sketchide.activities;

import android.os.Bundle;
import com.rajendra.sketchide.databinding.ActivityBackendBlockProgramBinding;

public class BackendBlockProgram extends BaseActivity {

private ActivityBackendBlockProgramBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

     binding = ActivityBackendBlockProgramBinding.inflate(getLayoutInflater());
     setContentView(binding.getRoot());

        setSupportActionBar(binding.toolbar);


    }
}