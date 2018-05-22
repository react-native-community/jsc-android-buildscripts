package com.zlotindaniel.robot;

import android.app.Instrumentation;
import android.support.test.InstrumentationRegistry;
import android.support.test.runner.AndroidJUnit4;
import android.support.test.uiautomator.By;
import android.support.test.uiautomator.BySelector;
import android.support.test.uiautomator.UiDevice;
import android.support.test.uiautomator.Until;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.IOException;

import static org.assertj.core.api.Assertions.assertThat;

@RunWith(AndroidJUnit4.class)
public abstract class BaseTest {
	public static final String PACKAGE_NAME = "com.javascriptcore.profiler";
	public static final long TIMEOUT = 15000;

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

	public void startJavaScriptCoreProfilerApp() throws Exception {
		device().executeShellCommand("am start -n " + PACKAGE_NAME + "/.MainActivity");
		device().waitForIdle();
		assertExists(By.pkg(PACKAGE_NAME).depth(0));
	}

	public void assertExists(BySelector selector) {
		assertThat(device().wait(Until.hasObject(selector), TIMEOUT))
				.withFailMessage("expected %1$s to be visible", selector).isTrue();
		assertThat(device().findObject(selector).getVisibleCenter().x)
				.isPositive()
				.isLessThan(device().getDisplayWidth());
		assertThat(device().findObject(selector).getVisibleCenter().y)
				.isPositive()
				.isLessThan(device().getDisplayHeight());
	}
}
