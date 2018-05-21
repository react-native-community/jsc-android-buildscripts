package com.zlotindaniel.robot;

import android.support.test.uiautomator.UiSelector;

import org.junit.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class EnvironmentTest extends BaseTest {
	@Test
	public void instrumentationAndAssertJ() throws Exception {
		assertThat(getInstrumentation().getTargetContext().getPackageName()).isEqualTo("com.zlotindaniel.robot");
	}

	@Test
	public void getTextFromDevice() throws Exception {
		device().executeShellCommand("am start -n " + PACKAGE_NAME + "/.MainActivity");
	}
}
