package com.javascriptcore.profiler;


import android.util.Log;

import com.facebook.react.ReactActivity;

import javax.annotation.Nullable;

public class MainActivity extends ReactActivity {
	@Nullable
	@Override
	protected String getMainComponentName() {
		return "MainScreen";
	}

	@Override
	protected void onResume() {
		super.onResume();
		Log.d(MainApplication.TAG, MainApplication.TAG + ":ActivityOnResume:" + System.currentTimeMillis());
	}
}
