# Lab 3: Add a Key

**Time:** About 30–40 minutes  

**You will:** Make the **P** key do something in the game by adding a little code to the player script.

---

## Step 1: Open the player script

1. In the **FileSystem** panel, go to **scripts** → **entities**.
2. Double-click **player.gd** to open it in the script editor.
3. Don’t worry about understanding everything. We’ll add code in one specific place.

---

## Step 2: Find the key-handling code

1. Press **Ctrl+F** (or **Cmd+F** on Mac) to search.
2. Search for: `match event.keycode:`
3. You should see a block that lists keys like `KEY_Q`, `KEY_F`, `KEY_TAB`, etc. Each one calls a function when you press that key.

---

## Step 3: Add the P key

1. Inside the `match event.keycode:` block, find a good spot (e.g. after `KEY_TAB` and before the closing of the match).
2. Add these two lines (use the same indentation as the other keys like `KEY_Q:`):

```gdscript
		KEY_P:
			_on_lab_key_pressed()
```

So it looks like the other keys. For example, near the character switch:

```gdscript
		# Character switch
		KEY_TAB:
			next_character()
		KEY_P:
			_on_lab_key_pressed()
```

3. Save the script (**Ctrl+S** or **Cmd+S**).

---

## Step 4: Add the function that runs when P is pressed

1. Scroll to the **bottom** of the file (after the `next_character()` function).
2. Add this new function:

```gdscript
func _on_lab_key_pressed() -> void:
	print("You pressed P!")
```

3. Save the script again.

---

## Step 5: Run and test

1. Press **F5** to run the game.
2. Press **P** (make sure the game window is focused).
3. In Godot, look at the **Output** panel at the bottom. You should see: `You pressed P!` every time you press P in the game.

If you don’t see the Output panel, go to **View → Output**.

---

## What you did

You connected a **key** (P) to a **function** (`_on_lab_key_pressed`). That’s the same pattern used for F (punch), Tab (switch character), and all the other keys. The game checks which key was pressed and calls the right function.

---

## Try it

Change what happens when you press P. For example:

- **Play an emote:** Replace the body of the function with:  
  `_play_action(ANIM_WAVE)`  
  Now P will make the character wave (same as key 1).

- **Print something else:** Change the string in `print("...")` to any message you like and run again.

---

## Challenge (optional)

- Add another key (e.g. **O**) that does something different. You’ll need to add `KEY_O:` in the match block and a new function.
- Or make P do something that uses the movement variables (e.g. temporarily change speed—ask your instructor for a hint).

---

## If something goes wrong

- **Red errors in the script:** Check spelling: `KEY_P`, `_on_lab_key_pressed`, and that the function is at the bottom of the file with `func` and `end` in the right place.
- **P does nothing:** Make sure the game window is in focus when you press P, and that you saved the script before running.
- **“Identifier not found”:** You probably added the `KEY_P:` line but forgot to add the `_on_lab_key_pressed()` function at the bottom.

---

## ✅ Done?

When pressing P runs your function (you see the print in Output or the character does the action you chose), you’re ready for **Lab 4: AI Director** (instructor-led).
