# aria2p

![aria2p](/assets/aria2p.gif)

- Repository: https://github.com/pawamoy/aria2p
- Documentation: https://pawamoy.github.io/aria2p

---

I like automating things, or at least making them scriptable,
controllable from the command line.
One of those "things" is downloading stuff from the internet.
I tried some GUI applications for torrents (Transmission, Deluge),
and was always disappointed by their lack of CLI-friendliness.

On [r/torrents](https://reddit.com/r/torrents), people pointed me to
[RTorrent](https://rakshasa.github.io/rtorrent/) (or is it RTorrent? rTorrent?),
which seems to be extremely configurable, scriptable, and powerful.
But it also seemed very complicated to grasp, particularly because it
implements its own configuration language.

So here I went again... doing things myself. Well, not really myself.
I chose to write a client for [aria2](https://aria2.github.io/), because
it offered an XML-RPC and a JSON-RPC interface.

And this is how `aria2p` was born!
I started by creating a client with nothing more, nothing less than what
`aria2` exposes in its JSON-RPC interface. And then I built upon that client
to provide more high-level methods.
The manual page of `aria2` is really well detailed, so it helped a lot.

I'm now running it on a RaspberryPi on which a hard-drive is plugged.
I can define callbacks (as Python functions) to process a download's files
when it finishes, like moving them in the right directory based on their
extension.

I really enjoyed writing this library and command-line tool,
and I poured all my experience in Python in this project's
management and configuration. I always use it as my sandbox for new
cutting edge analysis tools or static site generators.

I also learned how to write an HTOP-like interface, something I always
admired and wanted to try coding. There were some challenges, like
managing vertical+horizontal scroll while following a particular line or not,
as well as separating the data from the logic and the presentation,
or making the interface snappy, reacting fast to user input, without
loosing them. It's not finished though! There is room for a lot of improvements,
like charts at the top of the window, a status bar, additional views
for download details, configuration option, more actions, etc.

I want to write a tutorial on how to write an HTOP-like interface in Python
someday, using `aria2p` as an example. Such a tutorial would have helped me
tremendously back then, so I'm sure it would help other develoopers.
