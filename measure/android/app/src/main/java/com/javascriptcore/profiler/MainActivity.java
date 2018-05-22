package com.javascriptcore.profiler;


import android.util.Log;
import android.view.View;
import android.view.ViewTreeObserver;

import com.facebook.react.ReactActivity;
import com.facebook.react.ReactRootView;

import javax.annotation.Nullable;

public class MainActivity extends ReactActivity {
	@Nullable
	@Override
	protected String getMainComponentName() {
		return "MainScreen";
	}

	@Override
	public void setContentView(final View view) {
		super.setContentView(view);
		if (view instanceof ReactRootView) {
			view.getViewTreeObserver().addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {
				@Override
				public boolean onPreDraw() {
					if (((ReactRootView) view).getChildCount() > 0) {
						view.getViewTreeObserver().removeOnPreDrawListener(this);
						applicationLoadedAndRendered();
					}
					return true;
				}
			});

		}
	}

	private void applicationLoadedAndRendered() {
		long result = System.currentTimeMillis() - MainApplication.appStartTime;
		Log.d(MainApplication.TAG, MainApplication.TAG + ":ApplicationLoadedAndRendered:" + result);
	}
}
