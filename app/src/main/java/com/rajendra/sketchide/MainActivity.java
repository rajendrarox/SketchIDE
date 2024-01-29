package com.rajendra.sketchide;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.drawerlayout.widget.DrawerLayout;

import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageButton;
import android.widget.Toast;

import com.google.android.material.navigation.NavigationView;

public class MainActivity extends AppCompatActivity {

    DrawerLayout drawerLayout;
    ImageButton buttonDrawerToggle;
    NavigationView navigationView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        drawerLayout = findViewById(R.id.drawerLayout);
        buttonDrawerToggle = findViewById(R.id.buttonDrawerToggle);
        navigationView = findViewById(R.id.navigationView);

       // Navigation ImageButton Click to Open Navigation Menu
        buttonDrawerToggle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                drawerLayout.open();
            }
        });

        //Navigation Item Click Action
        navigationView.setNavigationItemSelectedListener(new NavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(@NonNull MenuItem item) {

                int ItemId = item.getItemId();

                if (ItemId == R.id.navAbout){
                    Toast.makeText(MainActivity.this, "Abuot Clicked", Toast.LENGTH_SHORT).show();
                }
                if (ItemId == R.id.navsettings){
                    Toast.makeText(MainActivity.this, "Settings Clicked", Toast.LENGTH_SHORT).show();
                }
                if (ItemId == R.id.navinformation){
                    Toast.makeText(MainActivity.this, "Information Clicked", Toast.LENGTH_SHORT).show();
                }
                if (ItemId == R.id.navtools){
                    Toast.makeText(MainActivity.this, "Tools Clicked", Toast.LENGTH_SHORT).show();
                }
                if (ItemId == R.id.navsign){
                    Toast.makeText(MainActivity.this, "Sign Clicked", Toast.LENGTH_SHORT).show();
                }

                drawerLayout.close();
                return false;
            }
        });



    }
}