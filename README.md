Vim-focusmotion
================
Context-dependent h/j/k/l motions for Vim.

How often have you pressed `jjjj` or `llllll` because you already had your
fingers on the hjkl keys and it was still faster than reaching for another
key(s)?

What if Vim could somehow guess, from the cursor position, than you don't mean
to move character-wise or one-line up/down?

Take this (awesome) piece of code:

```javascript
    console.log(
      Array.apply(null, {length: 100}).map(
        function(val, index) {
          index++;
          if (index % 15 == 0) {return "FizzBuzz";}
          if (index % 3  == 0) {return "Fizz";}
          if (index % 5  == 0) {return "Buzz";}
          return index;
        }
      ).join('\n')
    );
```

Say the cursor in on the `A` on the 2nd line. If you press `l`, is it more
likely that you want to move a few chars right within the first word, or that
you are trying to reach the `{length:` map literal, or the `100` value, or
some location close to those?

The cursor still on the `A`, if you press `j`, how often do you want to move
to that space just below, versus the first non-blank of the next line?
And don't you want, sometimes, to move directly to the closing line
`).join('\n)`?

This plugin lets you do so, by remapping h/j/k/l to motions that depend on your
cursor position within the current paragraph, indent block, line and word.

"Man, you're looney, just use w/b/f/}/42j, and cut that nonsense"
------------------------------------------------------------------
I use all these motions (except perhaps the `42j`). The point is that I want
better default motions for some specific cases, given that is what I need most
of the time. Once you get used to them, which admittedly can take some time,
you suddenly have the most useful motions right under the four keys you so
often use in Vim.

Check out the [manual](doc/focusmotion.txt) for usage and examples.

Installation
-------------
Use your favorite method:
*  [Pathogen][1] - `git clone https://github.com/fcpg/vim-focusmotion ~/.vim/bundle/vim-focusmotion`
*  [NeoBundle][2] - `NeoBundle 'fcpg/vim-focusmotion'`
*  [Vundle][3] - `Plugin 'fcpg/vim-focusmotion'`
*  manual - copy all of the files into your `~/.vim` directory

Help
-----
Run `:helptags` (or `:Helptags` with Pathogen), then `:help focusmotion`

[1]: https://github.com/tpope/vim-pathogen
[2]: https://github.com/Shougo/neobundle.vim
[3]: https://github.com/gmarik/vundle
