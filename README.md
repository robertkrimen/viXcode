# viXcode

viXcode is a [SIMBL](http://www.culater.net/software/SIMBL/SIMBL.php) plugin for providing vi/vim-style input in Xcode

It is a port of Jason Corso's Vi Input Manager (http://www.corsofamily.net/jcorso/vi/) to SIMBL

Some adjustments were made during the port to make the input handling more vi/vim-like. However, rough spots
still exist (e.g. 'dw' skipping over whitespace to delete a word) and need to be ironed out

## INSTALL

1. Download and install SIMBL: http://www.culater.net/dl/files/SIMBL-0.9.9.zip

2. Download and build viXcode

        git clone git://github.com/robertkrimen/viXcode.git
        ( cd viXcode && xcodebuild build )
        cp -R build/Release/viXcode.bundle $HOME/Library/Application Support/SIMBL/Plugins
        # Symbolically linking (ln -s) "viXcode.bundle" into "SIMBL/Plugins" will work too

3. Edit the Xcode key binding .plist to include the trigger key

        /Developer/Library/PrivateFrameworks/IDEKit.framework/Versions/A/Resources/IDETextKeyBindingSet.plist

Add the following somewhere in the IDETextKeyBindingSet.plist:

        <key>viXcode</key>
        <dict>
            <key>Open viXcode</key>
            <string>viXcode_Open:</string>
        </dict>

4. Launch Xcode and use "Preferences" > "Key Bindings" to associated "Open viXcode" with a key (or key combination)

        Control-`
        Command-;

---

# TODO:
* **Implement tests**
* Add option to prevent cursor jumping back to the start of the line
* Make 'e' stop at [, etc.
* Implement 'g' (gg)
* Implement 'J'
* Implement 'c?' ('s')
* dw: If on whitespace, delete only up to next word
