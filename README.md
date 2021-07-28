# Reverb Trickery
A free, open source audio plugin implementing various creative reverb effects, including octave-shifted, distorted, hi-pass/low-passed, gated, and narrowing reverb.


# Installation
Grab the latest release from https://github.com/unicornsasfuel/reverb_trickery/releases that corresponds to your operating system and supported plugin type, unzip it if it is zipped, and drop the file into the appropriate plugin directory or run the installer package.

Help finding VST3 locations can be found here: https://helpcenter.steinberg.de/hc/en-us/articles/115000177084-VST-plug-in-locations-on-Windows

Help finding AU locations can be found here: https://support.apple.com/en-us/HT201532

Since making macOS plugins that do not trigger Gatekeeper requires paying Apple $99 USD/yr for a developer license and I am not profiting from this software, this plugin will trigger Gatekeeper. Right click the installation package after downloading, and click "Open". When the prompt appears, click "Open" again to install the plugin.

# Building
This project is coded in Faust, so it can be built into any of the outputs Faust is capable of. A JUCE project is also provided, for building with Projucer.
