package com.zlotindaniel.robot;

import android.app.Instrumentation;
import android.support.test.InstrumentationRegistry;
import android.support.test.runner.AndroidJUnit4;
import android.support.test.uiautomator.UiDevice;

import org.junit.Before;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public abstract class BaseTest {
	public static final String PACKAGE_NAME = "com.javascriptcore.profiler";

	@Before
	public void beforeEach() throws Exception {
		device().wakeUp();
	}

	public void afterEach() throws Exception {
		device().executeShellCommand("am force-stop " + PACKAGE_NAME);
	}

	public UiDevice device() {
		return UiDevice.getInstance(getInstrumentation());
	}

	public Instrumentation getInstrumentation() {
		return InstrumentationRegistry.getInstrumentation();
	}
}
