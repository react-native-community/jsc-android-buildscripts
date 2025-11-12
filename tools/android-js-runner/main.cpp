#include <JavaScript.h>

#include <cstdlib>
#include <chrono>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>

namespace {

std::string valueToString(JSGlobalContextRef ctx, JSValueRef value)
{
    JSValueRef exception = nullptr;
    JSStringRef stringRef = JSValueToStringCopy(ctx, value, &exception);
    if (exception) {
        JSStringRef exceptionStr = JSValueToStringCopy(ctx, exception, nullptr);
        size_t exceptionMaxSize = JSStringGetMaximumUTF8CStringSize(exceptionStr);
        std::vector<char> exceptionBuffer(exceptionMaxSize);
        JSStringGetUTF8CString(exceptionStr, exceptionBuffer.data(), exceptionMaxSize);
        JSStringRelease(exceptionStr);
        throw std::runtime_error(exceptionBuffer.data());
    }

    size_t maxSize = JSStringGetMaximumUTF8CStringSize(stringRef);
    std::vector<char> buffer(maxSize);
    JSStringGetUTF8CString(stringRef, buffer.data(), maxSize);
    JSStringRelease(stringRef);
    return std::string(buffer.data());
}

std::string evaluateToString(JSGlobalContextRef ctx, const char* source)
{
    JSStringRef script = JSStringCreateWithUTF8CString(source);
    JSValueRef exception = nullptr;
    JSValueRef result = JSEvaluateScript(ctx, script, nullptr, nullptr, 0, &exception);
    JSStringRelease(script);

    if (exception) {
        throw std::runtime_error(valueToString(ctx, exception));
    }

    return valueToString(ctx, result);
}

void runSmokeTest(JSGlobalContextRef ctx)
{
    evaluateToString(
        ctx,
        "if (typeof PrivateSymbol === 'undefined') {\n"
        "  globalThis.PrivateSymbol = { asyncContext: Symbol('asyncContext') };\n"
        "} else if (!PrivateSymbol.asyncContext) {\n"
        "  PrivateSymbol.asyncContext = Symbol('asyncContext');\n"
        "}"
    );

    evaluateToString(
        ctx,
        "var __jscSmokeTestResult = undefined;\n"
        "Promise.resolve().then(function() {\n"
        "  throw {value: JSON.stringify({foo: 1})};\n"
        "}).catch(function(error) {\n"
        "  __jscSmokeTestResult = error.value;\n"
        "});\n"
        "__jscSmokeTestResult;");

    std::string capturedResult = evaluateToString(
        ctx,
        "typeof __jscSmokeTestResult === 'string'\n"
        "  ? __jscSmokeTestResult\n"
        "  : __jscSmokeTestResult === undefined ? 'pending' : String(__jscSmokeTestResult);");

    if (capturedResult != "{\"foo\":1}") {
        throw std::runtime_error("Unexpected result: " + capturedResult);
    }
}

JSObjectRef compileScriptToFunction(JSGlobalContextRef ctx, const std::string& source)
{
    std::string wrapped = "(function(){\n" + source + "\n})";
    JSStringRef wrapperString = JSStringCreateWithUTF8CString(wrapped.c_str());
    JSValueRef exception = nullptr;
    JSValueRef value = JSEvaluateScript(ctx, wrapperString, nullptr, nullptr, 0, &exception);
    JSStringRelease(wrapperString);

    if (exception)
        throw std::runtime_error(valueToString(ctx, exception));

    if (!JSValueIsObject(ctx, value))
        throw std::runtime_error("Compiled value is not a function");

    JSObjectRef functionObject = JSValueToObject(ctx, value, &exception);
    if (exception)
        throw std::runtime_error(valueToString(ctx, exception));

    return functionObject;
}

struct ExecutionResult {
    std::string result;
    double durationMs { 0.0 };
};

ExecutionResult executeScriptWithTiming(JSGlobalContextRef ctx, const std::string& script)
{
    JSObjectRef functionObject = compileScriptToFunction(ctx, script);

    JSValueRef exception = nullptr;
    auto start = std::chrono::steady_clock::now();
    JSValueRef value = JSObjectCallAsFunction(ctx, functionObject, nullptr, 0, nullptr, &exception);
    auto end = std::chrono::steady_clock::now();

    if (exception)
        throw std::runtime_error(valueToString(ctx, exception));

    ExecutionResult execResult;
    execResult.result = valueToString(ctx, value);
    execResult.durationMs = std::chrono::duration<double, std::milli>(end - start).count();
    return execResult;
}

} // namespace

int main(int argc, char** argv)
{
    JSGlobalContextRef context = JSGlobalContextCreate(nullptr);
    if (!context) {
        std::cerr << "Failed to create JavaScript context" << std::endl;
        return EXIT_FAILURE;
    }

    std::string scriptSource;
    bool hasCustomScript = false;

    if (argc > 1) {
        hasCustomScript = true;
        std::string firstArg = argv[1];
        if (firstArg == "--file" || firstArg == "-f") {
            if (argc < 3) {
                std::cerr << "Missing file path after --file" << std::endl;
                JSGlobalContextRelease(context);
                return EXIT_FAILURE;
            }
            std::ifstream inFile(argv[2]);
            if (!inFile) {
                std::cerr << "Failed to read script file: " << argv[2] << std::endl;
                JSGlobalContextRelease(context);
                return EXIT_FAILURE;
            }
            scriptSource.assign(std::istreambuf_iterator<char>(inFile), std::istreambuf_iterator<char>());
        } else {
            // Concatenate all arguments into a single script string.
            scriptSource = argv[1];
            for (int i = 2; i < argc; ++i) {
                scriptSource.append(" ");
                scriptSource.append(argv[i]);
            }
        }
    }

    try {
        if (hasCustomScript) {
            ExecutionResult execResult = executeScriptWithTiming(context, scriptSource);
            std::cout << "RESULT: " << execResult.result << std::endl;
            std::cout << "TIME_MS: " << execResult.durationMs << std::endl;
        } else {
            runSmokeTest(context);
            std::cout << "PASS" << std::endl;
        }
    } catch (const std::exception& error) {
        std::cerr << "FAIL: " << error.what() << std::endl;
        JSGlobalContextRelease(context);
        return EXIT_FAILURE;
    }

    if (!hasCustomScript) {
        JSGarbageCollect(context);
        JSGlobalContextRelease(context);
    }
    return EXIT_SUCCESS;
}
