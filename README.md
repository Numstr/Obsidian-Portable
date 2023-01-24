# Obsidian Portable

[Obsidian](https://github.com/obsidianmd/obsidian-releases) Portable based on [PortableApps Launcher](https://portableapps.com/apps/development/portableapps.com_launcher), with a batch file for easy install / upgrade.

## ObsidianPortable.ini

The `AdditionalParameters` entry allows you to pass additional command-line
parameters to the application.

The `RunLocally` entry allows you to run the portable application from a read-
only medium. This is known as Live mode. It copies what it needs to to a
temporary directory on the host computer, runs the application, and then
deletes it afterwards, leaving nothing behind. This can be useful for running
the application from a CD or if you work on a computer that may have spyware or
viruses and you'd like to keep your device set to read-only. As a consequence
of this technique, any changes you make during the Live mode session aren't
saved back to your device.
