# SyphonWeb

This is a really basic macOS app (macOS 12.0+ and Swift 6.1.0+) that renders a web view to [Syphon](https://syphon.info) so you can use it in many live visual suites like VDMX and TouchDesigner.

It's currently hard coded in `main.swift` to render to Syphon using the Metal API at 1280x720 and generally can send frames at at least 30 fps depending on the complexity of the webpage. 

# Developing

Everything you need should be in this repo, including the pre-built Syphon framework that I converted into a `.xcframework` so you don't need to use Xcode. Along with a few hacks to make using VSCode easier with Syphon's framework.

Just execute `swift run` from the command line and it should boot right up!

I'll update this app to be a few more features in the future. Until then I hope it's a useful app!

# Building App Bundle

Because this project doesn't use Xcode, so it takes a more rough approach to creating an app bundle.

Basically a "skeleton" app is filled up with the framework and binary, then patched to run properly. 

There's a `build_app.sh` script that should do app the steps required, and produce a `SyphonWeb.app` bundle in the root of the repo.

# Limitations

Videos (like YouTube) do not render in the frame output, this is because they're rendered on a difference CoreGraphics context layer that we don't have access to. But I wrote this app to render Processing.js and HTML5 animation content into my VDMX setup, so that's not a huge deal breaker for me.

Enjoy!

Made with 🐾 by Digit (@doawoo)