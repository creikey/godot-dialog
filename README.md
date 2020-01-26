# godot-dialog
A simple system for conversational dialog, featuring a full fledged editor for none programmers and an example json parser. To add a new node you simply right click on the node graph, to pan use middle mouse button, and click and drag to move nodes around or connect them to one another.

![example image](https://raw.githubusercontent.com/creikey/godot-dialog/master/cover-image.png)

## Download

https://creikey.itch.io/godot-dialog

## Format specification

### Definitions

`state node` - a different state for the character to be in

`state` - the emotion, or state, of the text shown in the current `state node`

`text` - what the character says at that current `state node`

`choices` - the different choices the player can make when talking to the character

`state stub` - a helper `state node` used in the dialog editor to manage a sequence of related `state node`s

### Special notes

 - States are stored as strings to remove floating point comparison errors in godot
 - At state `0`, the dialog is over
 - States with no choices contain a `next` key that specifies the next state, typically after user input. This is used to provide different emotional states for one chain of dialog
 - State that has the choice "inherit" will inherit the last used choices, useful for simple dialog

Dialog consists of a json file, which contains a root dictionary of states, as such:
```
{
	"1" : {
		"state" : "happy",
		"text" : "I'm feeling happy!",
		"choices" : {
			"Why do you feel happy?" : "2",
			"Goodbye" : "0"
		}
	}
	"2" : {
		"state" : "confused",
		"text" : "Because I do!?",
		"next" : "3"
	}
	"3" : {
		"state" : "normal",
		"text" : "Why would you even ask something like that?",
		"choices" : "inherit"
	}
}
```
There may be extra metadata keys unrelated to states to recreate the dialog in the editor
