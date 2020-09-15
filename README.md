# Minesweeper
My version of Minesweeper.

My implementation is fairly unique in that it does not require a grid of 1x1 squares. The number entered in the "Size:" box determines the maximum size of blobs used to create the minefield. The same adjacency rules apply. A blob is adjacent to any other blob that contacts a side or vertex of the original. Also, the mines are only added after your first click, so you will never lose on the first clear.

Left Click to clear a blob. Right Click to add or remove a flag. Shift Click or Middle Click a blob with all adjacent blobs flagged to clear any other adjacent blobs. (MATLAB does not differentiate between a Double Left Click and a Double Right Click, so if you click too rapidly nothing will happen to prevent mistakes. I usually encountered this when attempting to remove a flag I misplaced.)

Using text boxes at the top of the figure, you can change the size of the grid, the number of mines, and as mentioned, the maximum blob size.

![](https://i.imgur.com/Ets4rzQ.png)

This was originally coded with a fixed blob size of 2, which was <em>much</em> simpler. The blob generation code was later repurposed to make [KenKen](https://github.com/climber59/KenKen). It was also an excuse to practice making a class in MATLAB, though I don't think I would code it that way again. I believe everything I stored in the class could have also been stored in the patch's UserData.

This game could still use a lot of polish.
