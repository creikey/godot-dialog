# godot-dialog
A simple system for conversational dialog, featuring a full fledged editor for none programmers and an example json parser

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
		"choices" : {
			"Alright then..." : "1"
		}
	}
}
```
There may be extra metadata keys unrelated to states to recreate the dialog in the editor
