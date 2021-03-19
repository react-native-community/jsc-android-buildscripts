package com.test;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.matcher.ViewMatchers.withText;
import static androidx.test.espresso.matcher.ViewMatchers.isRoot;
import static androidx.test.espresso.assertion.ViewAssertions.matches;

import android.view.View;

import androidx.test.core.app.ActivityScenario;
import androidx.test.espresso.ViewAction;
import androidx.test.espresso.UiController;
import androidx.test.espresso.PerformException;
import androidx.test.espresso.util.TreeIterables;
import androidx.test.espresso.util.HumanReadables;
import androidx.test.filters.LargeTest;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import java.util.concurrent.TimeoutException;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import org.hamcrest.Matcher;

@RunWith(AndroidJUnit4.class)
@LargeTest
public class SimpleTest {

    @Before
    public void launchActivity() {
      ActivityScenario.launch(MainActivity.class);
    }

    @Test
    public void testIfAppLoads() {
      onView(isRoot()).perform(waitText("Welcome to React", 10000));
    }

    public static ViewAction waitText(final String text, final long millis) {
      return new ViewAction() {
        @Override
        public Matcher<View> getConstraints() {
            return isRoot();
        }

        @Override
        public String getDescription() {
            return "wait for a specific view with text <" + text + "> during " + millis + " millis.";
        }

        @Override
        public void perform(final UiController uiController, final View view) {
            uiController.loopMainThreadUntilIdle();
            final long startTime = System.currentTimeMillis();
            final long endTime = startTime + millis;
            final Matcher<View> viewMatcher = withText(text);

            do {
                for (View child : TreeIterables.breadthFirstViewTraversal(view)) {
                    // found view with required ID
                    if (viewMatcher.matches(child)) {
                        return;
                    }
                }

                uiController.loopMainThreadForAtLeast(50);
            }
            while (System.currentTimeMillis() < endTime);

            // timeout happens
            throw new PerformException.Builder()
                    .withActionDescription(this.getDescription())
                    .withViewDescription(HumanReadables.describe(view))
                    .withCause(new TimeoutException())
                    .build();
        }
    };
  }
}
