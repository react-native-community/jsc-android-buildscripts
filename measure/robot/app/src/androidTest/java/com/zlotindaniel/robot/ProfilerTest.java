package com.zlotindaniel.robot;

import android.support.test.uiautomator.By;
import android.support.test.uiautomator.Until;

import org.junit.Test;

public class ProfilerTest extends BaseTest {
//	@Test
//	public void javascriptSynthetics() throws Exception {
//		startJavaScriptCoreProfilerApp();
//		device().findObject(By.text("Profile JavaScript".toUpperCase())).click();
//		assertExists(By.text("DONE"));
//	}

	@Test
	public void renderFlat() throws Exception {
		startJavaScriptCoreProfilerApp();
		click("Profile Render Flat");
		click("OK");
	}

//	@Test
//	public void renderDeep() throws Exception {
//		startJavaScriptCoreProfilerApp();
//		click("Profile Render Deep");
//		click("OK");
//	}
//
//	@Test
//	public void renderDeep2() throws Exception {
//		startJavaScriptCoreProfilerApp();
//		click("Profile Render Deep");
//		click("OK");
//	}
}
