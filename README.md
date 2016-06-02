# urist-dicehammer
Discord dice bot written in Ruby.

## Commands

**!roll** - rolls dice. First argument is a dice string with the following options:
* **!roll 1d6** rolls a six-sided die.
* **!roll 3d6** rolls three six-sided dice, giving a total and the results in order.
* **!roll 6#3d6** rolls three six-sided dice six times, with separate totals and results.
* **!roll 3d20+3** rolls three six-sided dice and adds 3 to the total. Modifier can be positive or negative.

Additional arguments to !roll are given after the dice string. Currently the only one is **drop**.
* **!roll 4d6 drop lowest** will roll four six-sided dice and exclude the smallest result from the total. (It will still be in the results.)
* **!roll 4d6 drop 2 highest** will roll four six-sided dice and exclude the largest two results from the total.

**!coinflip** - flips coins. Defaults to one coin, use **!coinflip n** to flip any number of coins.

**!toggle** - changes bot server-specific switches to either ''on'' or ''off''.
* **!toggle memes** sets joke responses on or off for this server.
