package com.rajendra.sketchide.fragments

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import com.google.android.material.navigationrail.NavigationRailView
import com.rajendra.sketchide.R

class LogicFragment : Fragment() {

    private lateinit var navController: NavController

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.fragment_logic, container, false)

        // Find NavigationRailView
        val navigationRailView = view.findViewById<NavigationRailView>(R.id.navigationRailView)

        // Get NavController from NavHostFragment
        val navHostFragment = childFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment
        navController = navHostFragment.navController

        // Set NavigationRailView onItemSelectedListener
        navigationRailView.setOnItemSelectedListener { item ->
            when (item.itemId) {
                R.id.logic_activity -> {
                    // Handle navigation to destination nav_logic_fragment_activity
                    navController.navigate(R.id.nav_logic_fragment_activity)
                    true
                }
                R.id.logic_view -> {
                    // Handle navigation to destination nav_logic_fragment_view
                    navController.navigate(R.id.nav_logic_fragment_view)
                    true
                }
                R.id.logic_component -> {
                    // Handle navigation to destination nav_logic_fragment_view
                    navController.navigate(R.id.nav_logic_fragment_component)
                    true
                }
                R.id.logic_drawer -> {
                    // Handle navigation to destination nav_logic_fragment_view
                    navController.navigate(R.id.nav_logic_fragment_drawer)
                    true
                }
                R.id.logic_more_block -> {
                    // Handle navigation to destination nav_logic_fragment_view
                    navController.navigate(R.id.nav_logic_fragment_more_block)
                    true
                }
                else -> false
            }
        }

        return view
    }
}
