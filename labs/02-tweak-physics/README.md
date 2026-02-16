# Lab 2: Tweak Physics

**Time:** About 25–35 minutes  

**You will:** Change the character’s walk speed, jump height, and gravity using the Godot Inspector—no typing code.

---

## Step 1: Open the main scene

1. In the **FileSystem** panel (left side), go to **scenes**.
2. Double-click **main.tscn** to open it.
3. You should see the 3D view and a tree of nodes on the left (e.g. Main, Player, WorldEnvironment).

---

## Step 2: Select the Player

1. In the **Scene** tree (left), click the **Player** node.
2. The **Inspector** (right side) will show properties for the Player.
3. Find the **Movement** group. You should see things like:
   - Walk Speed  
   - Catwalk Speed  
   - Run Speed  
   - Jump Velocity  
   - Gravity  

---

## Step 3: Change a value

1. Click the number next to **Walk Speed** (default is something like 3).
2. Type a new number. Try **6** (faster) or **1** (slower).
3. Save the scene: **Ctrl+S** (Windows/Linux) or **Cmd+S** (Mac).

---

## Step 4: Run and test

1. Press **F5** to run the game.
2. Move with **W A S D**. Does the character walk faster or slower than before?
3. Close the game (or stop it in Godot) and change **Walk Speed** again. Run and test once more.

---

## Step 5: Try other values

Change one at a time, then run the game each time:

- **Jump Velocity** – Try **8** (higher jump) or **2** (lower jump).
- **Gravity** – Try **5** (floatier) or **15** (heavier). Be careful: very high or very low numbers can feel weird.
- **Run Speed** – Make it higher or lower and see how running feels.

After each change, save the scene and run the game to see what happens.

---

## What’s going on?

The game script uses these numbers as **variables**. By changing them in the Inspector, you change how the game behaves without editing code. Game designers do this all the time to “tune” how a character feels.

---

## Challenge (optional)

- Find values for Walk Speed, Jump Velocity, and Gravity that make the character feel like they’re on the moon (low gravity, high jump).
- Then try values that make them feel like they’re running super fast.

---

## ✅ Done?

When you’ve changed at least two different movement values and seen the effect in the game, you’re ready for **Lab 3: Add a Key**.
