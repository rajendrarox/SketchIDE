package com.rajendra.sketchide;

import android.content.Context;
import android.util.Log;

import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.*;

import com.rajendra.sketchide.utils.StorageUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * Instrumented test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class ExampleInstrumentedTest {
    @Test
    public void useAppContext() {
        // Context of the app under test.
        Context appContext = InstrumentationRegistry.getInstrumentation().getTargetContext();
        assertEquals("com.rajendra.sketchide", appContext.getPackageName());

        List<String> lines = new ArrayList<>();
        lines.add("line 1");
        lines.add("line 2");

        StorageUtils.writeToFile(appContext, "test.txt", lines);

        List<String> answer = StorageUtils.readFromFile(appContext, "test.txt");
        int n = 0;
        for (String line : answer) {
            assertEquals(lines.get(n), line);
        }
    }
}