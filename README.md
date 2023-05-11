# AdventOfCode2022Day16
This is my solution for the [Advent of Code 2022 Day 16 2022](https://adventofcode.com/2022/day/16) in elixir. TLDR: 
*Part A:* There are a number of valves connected in a graph that release pressure when opened. I can go to the valves, which takes time, and open valves, which takes time. I want to release the most pressure possible given a graph in 30 min.
*Part B:* Now I have an a second person that helpes me to open valves, which complicates the solution a lot.

## Solution Part A
I first compute the distance between each valve using dijkstras algorithm. Then I use depth first search to find the best way to go through the graph.
## Solution Part B
For this solution I check every minute if one of the players can move. If they can I use a similar approach as in part A but now I do the heuristic that if a valve releases less pressure and is further away, I probably don't want to open it, so I don't try it in the depth first search. This results into a faster runtime.

To get a more in-depth understanding of what I did, please read the [report](https://github.com/sonnenpelzx/AdventOfCode2022Day16/blob/main/Advent_of_Code_16_Report.pdf)
 
## How to run this program
Clone the repository, open it with the elixir shell and run q16(30) for part A or q16b(26) for part B in c16.ex
