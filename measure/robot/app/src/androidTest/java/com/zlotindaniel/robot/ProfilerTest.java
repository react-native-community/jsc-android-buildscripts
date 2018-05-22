package com.zlotindaniel.robot;

import android.support.test.uiautomator.By;
import android.support.test.uiautomator.Until;

import org.junit.Test;

public class ProfilerTest extends BaseTest {
	@Test
	public void runAllProfilerTests() throws Exception {
		startJavaScriptCoreProfilerApp();
		device().findObject(By.text("Profile JavaScript".toUpperCase())).click();
		assertExists(By.text("DONE"));
	}
}
