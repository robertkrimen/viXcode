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

## USAGE

<table>
<col align="center" />
<col align="left" />
<thead>
</thead>
<tbody>
<tr>
	<td align="center"><code>{</code></td>
	<td align="left">Move to beginning of previous paragraph</td>
</tr>
<tr>
	<td align="center"><code>}</code></td>
	<td align="left">Move to beginning of next paragraph</td>
</tr>
<tr>
	<td align="center"><code>$</code></td>
	<td align="left">Move to the end of the line</td>
</tr>
<tr>
	<td align="center"><code>?</code></td>
	<td align="left">Begin searching reverse, repeat last search in reverse</td>
</tr>
<tr>
	<td align="center"><code>/</code></td>
	<td align="left">Begin searching forward, repeat last search forward</td>
</tr>
<tr>
	<td align="center"><code>_</code></td>
	<td align="left"><s>Move to the beginning of the line</s></td>
</tr>
<tr>
	<td align="center"><code>^</code></td>
	<td align="left">Move to the first non-blank character of current line</td>
</tr>
<tr>
	<td align="center"><code>0</code></td>
	<td align="left">Move to the beginning of the line</td>
</tr>
<tr>
	<td align="center"><code>a</code></td>
	<td align="left">Enter insert mode after the current point</td>
</tr>
<tr>
	<td align="center"><code>A</code></td>
	<td align="left">Enter insert mode at the end of the current line</td>
</tr>
<tr>
	<td align="center"><code>b,B</code></td>
	<td align="left">Move one word backward</td>
</tr>
<tr>
	<td align="center"><code>cw,c#w</code></td>
	<td align="left">Change word (or multiple)</td>
</tr>
<tr>
	<td align="center"><code>dd,d#d</code></td>
	<td align="left">Delete one or more lines, e.g., dd, d2d, d34d</td>
</tr>
<tr>
	<td align="center"><code>dh,d#h</code></td>
	<td align="left">Delete character from current location * left, e.g., dh, d2h, d34h</td>
</tr>
<tr>
	<td align="center"><code>dj,d#j</code></td>
	<td align="left">Delete character from current location * down, e.g., dj, d2j, d34j</td>
</tr>
<tr>
	<td align="center"><code>dk,d#k</code></td>
	<td align="left">Delete character from current location * up, e.g., dk, d2k, d34k</td>
</tr>
<tr>
	<td align="center"><code>dl,d#l</code></td>
	<td align="left">Delete character from current location * right, e.g., dl, d2l, d34l</td>
</tr>
<tr>
	<td align="center"><code>dw,d#w</code></td>
	<td align="left">Delete a word (or multiple)</td>
</tr>
<tr>
	<td align="center"><code>d$</code></td>
	<td align="left">Delete to end of line</td>
</tr>
<tr>
	<td align="center"><code>e,E</code></td>
	<td align="left">Move to end of word</td>
</tr>
<tr>
	<td align="center"><code>G,#G</code></td>
	<td align="left">Move to last line, or line number #</td>
</tr>
<tr>
	<td align="center"><code>h</code></td>
	<td align="left">Move left</td>
</tr>
<tr>
	<td align="center"><code>i</code></td>
	<td align="left">Enter insert mode</td>
</tr>
<tr>
	<td align="center"><code>I</code></td>
	<td align="left">Enter insert mode at the beginning of the current line</td>
</tr>
<tr>
	<td align="center"><code>j</code></td>
	<td align="left">Move down</td>
</tr>
<tr>
	<td align="center"><code>k</code></td>
	<td align="left">Move up</td>
</tr>
<tr>
	<td align="center"><code>l</code></td>
	<td align="left">Move right</td>
</tr>
<tr>
	<td align="center"><code>n</code></td>
	<td align="left">Repeat last search in the same direction</td>
</tr>
<tr>
	<td align="center"><code>N</code></td>
	<td align="left">Repeat last search in the opposite direction</td>
</tr>
<tr>
	<td align="center"><code>o</code></td>
	<td align="left">Enter insert mode on a new line</td>
</tr>
<tr>
	<td align="center"><code>O</code></td>
	<td align="left">Enter insert mode on a new line above</td>
</tr>
<tr>
	<td align="center"><code>p</code></td>
	<td align="left"><s>Puts back whatever is in the "kill" buffer (via Coca directly)</s></td>
</tr>
<tr>
	<td align="center"><code>r\</code>*</td>
	<td align="left">Replace the character under the cursor with typed character</td>
</tr>
<tr>
	<td align="center"><code>u</code></td>
	<td align="left">Undo last operation (this uses the Cocoa UndoManager directly)</td>
</tr>
<tr>
	<td align="center"><code>w,W</code></td>
	<td align="left">Move one word forward</td>
</tr>
<tr>
	<td align="center"><code>x</code></td>
	<td align="left">Delete character under the cursor</td>
</tr>
</tbody>
</table>

---

# TODO:
* **Implement tests**
* Add option to prevent cursor jumping back to the start of the line
* Make 'e' stop at [, etc.
* Implement 'J'
* Implement 'c?' ('s')
* dw: If on whitespace, delete only up to next word
* http://www.corsofamily.net/jcorso/vi/#visupport
