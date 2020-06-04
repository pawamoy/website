---
title: About
permalink: /about/
---

<style>
.post-header {
  display: none;
}

code {
  border: none;
  padding: 0;
  font-weight: bold;
}

p {
  margin-left: 40px !important;
}

p.i2 {
  display: none;
}

p.i2 + p {
  margin-left: 80px !important;
}

p a,
p a:hover,
p a:visited {
  text-decoration: underline;
}

ul {
  list-style-type: none;
}

</style>

#### **NAME**
`pawamoy` — Timothée Mazzucotelli

#### **SYNOPSIS**
`pawamoy [GLOBAL_OPTS] COMMAND [COMMAND_OPTS] [OBJECT | IDEA]...`

#### **DESCRIPTION**
`pawamoy` lets you take control over the person identified by the name
*Timothée Mazzucotelli*.

Timothée Mazzucotelli was born in France and still lives there.
He received education in Computer Science and obtained
his Masters in C.S. in Université de Strasbourg.
He is therefore able to write code, amongst other things (see [COMMANDS](#commands)).

#### **GLOBAL OPTIONS**
These options influence how the command will be run.
Please note that some switches may not apply to some commands.

`--chatty`

<p class="i2"></p>
Increase verbosity. This flag is automatically switched on when command `drink`
is used with option `--alcohol`. Default: false.

`--enthusiast`

<p class="i2"></p>
This option is always useful, especially when learning new things.
Use it without caution!

`--fast`

<p class="i2"></p>
Do things fast. Behavior becomes non-deterministic: things will be done well
in average, but sometimes they will not. This option can yield more interesting
results though.

`--happy`

<p class="i2"></p>
Everyone wants to be happy right? Use this option regularly to ensure proper
sanity of mind.

`--introvert`

<p class="i2"></p>
Act with more reserve. Talk less. This option overrides and disables `--chatty`.
There is a high probability that `--over-thinking` will be switched on using
`--introvert`. This option can be used to avoid unnecessary jokes
during professional interactions, but try not to use it too much
as it will reduce enthusiasm and increase risk of switching `--silent` on.

`--open`

<p class="i2"></p>
Stay open! Every thing you hear or see will be received
with more curiosity and enthusiasm.
Best used in combination with `learn` and `work` commands.

`--over-thinking`

<p class="i2"></p>
Spend more time thinking about things than actually doing them.

`--perfectionist`

<p class="i2"></p>
Nothing is ever good enough. Use this option to enable a
"constantly-improving-and-refactoring" behavior. Beware: time spent in this mode
is exponentially increased, and there is no guarantee to obtain a final product!

`--reluctant`

<p class="i2"></p>
When inspiration is low, reluctant mode is activated. Things will be harder
at first, but once the machinery is warmed-up, this mode will be deactivated
and behavior will go back to normal.

`--safe`

<p class="i2"></p>
Sometimes things are dangerous. Use this mode to increase cautiousness and
avoid accidents.

`--silent`

<p class="i2"></p>
Do not say a word and be silent. This mode can be used to silently sneak behind
someone and surprise them. Be sure to know the person though. This mode is also
used at night, to avoid waking up the significant other.

`--slow`

<p class="i2"></p>
Side-effect of `--reluctant`, also triggered when tired. Everyone needs a bit
of slowness from time to time right?


#### **COMMANDS**
`code`

<p class="i2"></p>
Write or design code. It implies thinking, and can imply drawing. This command
can be run regularly, without moderation. It should not be used 100% of the time
though, because other vital tasks need attention.

`drink`

<p class="i2"></p>
Drink liquids. Options are: `--water` (the default),
`--juice`, `--alcohol` and `--soda`.
Juices are good in the morning, while alcohol is better for social events,
though not mandatory.
Soda is really an extra, for example when eating pizza (both go well
together). Water is mandatory. A bottle of it must always be available at night.

`eat`

<p class="i2"></p>
Eat food. Almost every kind of food is accepted as positional argument.
Ability to eat insects is not yet implemented, but might be in the future.

`exercise`

<p class="i2"></p>
Exercise command should be run regularly, like two or three times a week.
Option `--bike` is built-in and very often used as the main transport mean.
Currently, option `--badminton` is available,
and soon maybe `--basketball` will be implemented.

`learn`

<p class="i2"></p>
Learn new things. It takes time and depending on the thing to learn,
`--relucant` might be enabled at first.
In any case, don't forget to use the `--open` global option to
ease the process.
One thing that seems to be instantly learned and remembered
is new keyboard shortcuts.

`listen`

<p class="i2"></p>
Focus on listening. Probability of talking is decreased.
This command is well used when someone is asking a question.
It helps preventing an anticipation bias that often leads
to an incorrect comprehension of the question, and thus an incorrect answer.

`love`

<p class="i2"></p>
You can love many things and people. Don't restrict yourself.
Isn't love a choice after all? Brutal black metal was not loved at first,
it took a bit of time and training to be able to listen to it,
but now it's one of the most-cherished thing!

`play`

<p class="i2"></p>
Play single or multi-player. Card games, video games,
especially horror ones, all sorts of games!
Option `--vr` is already implemented but is waiting for adequate hardware.

`read`

<p class="i2"></p>
Read a book, an article, on joke, docs, a tutorial, news.
Read it on a desktop screen, on a smartphone screen, on an e-book screen, or...
on paper directly? Technology is crazy. While using this option,
please take care of your eyes: enable blue-light filters and adapt luminosity.

`sleep`

<p class="i2"></p>
Sleep must be done regularly and in sufficient quantity
to ensure proper performance in any other activity.
Run this command at least once per day (better during the night)
for at least eight hours. More is better.
Less, and headache will appear, and `--reluctant` flag
will be turned on until more sleep is done.

`talk`

<p class="i2"></p>
Talk about universal determinism at parties.

`think`

<p class="i2"></p>
Don't start to write code for your complex project idea immediately!
Think it before! But be careful: **not too much**. You'll want to implement
all the options. Yes, all. It will end as a generic program to do anything,
and it will fail.

`work`

<p class="i2"></p>
Chop chop! It's time to work! But your work is your passion,
so it's not really work, is it?

`write`

<p class="i2"></p>
Write man pages, blog posts, documentation, code, fiction.
You should write more fiction.

#### **BUGS**
`pawamoy` has an extra pair of ribs.
This bug does not come from the two engineers that designed `pawamoy`.
It is due to some binary data corruption during replication over network.
It can't be fixed.

#### **COPYRIGHT**
Copyright 1991-2009 Mazzucotelli Foundation, Inc.

This is proprietary software; see the source for copying conditions.
There is **NO** warranty; not even for MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.

#### **ENVIRONMENT VARIABLES**
`HOME` - Define the home `pawamoy` will use.
"Moon", "Area 51", or "Public bathrooms" are not valid values.

`ENERGY` - An integer between 1 and 100.
Using 0 will cause `pawamoy` to self-destruct.
Use with caution.
Use commands `eat` then `sleep` when `ENERGY` is low to increase it again.

`HEALTH` - An integer between 1 and 100.
Using 0 is reserved for the end-of-life date of `pawamoy`.
Don't use it before.

`HUNGER` - An integer between 1 and 100. 0 mens extra-full, 100 means starving.
Use command `eat` to decrease `HUNGER`.

`TEMPERATURE` - In degree Celsius.
Try to increase it just a bit when `HEALTH` is lowering.
This is experimental. Use it at my own risk.


#### **FILES**
`/boot/config` - This file was useful only once, because `pawamoy` can never
reboot. Once shut down, it stays shut down.

`/sys/cpu` - This file was auto-generated, and is self-mutating. Please
don't mess too much with this file.

`/etc/pawamoy/principles` - You can modify principles here. Don't add too many.

`/var/log/pawamoy` - Interesting statistics and analytics about `pawamoy` usage.


#### **LICENSE**
`pawamoy` is released under the terms of the `Human Decency` license.
Please use it accordingly.
You cannot duplicate `pawamoy`. At least for now.

#### **SEE ALSO**
[`@pawamoy(dev.to)`](https://dev.to/pawamoy),
[`@pawamoy(github)`](https://github.com/pawamoy/),
[`@paaawamoy(instagram)`](https://www.instagram.com/paaawamoy/),
[`@pawamoy(reddit)`](https://reddit.com/u/pawamoy/),
[`@pawamoy(stackoverflow)`](https://stackoverflow.com/users/3451029/pawamoy),
[`@pawamoy(twitter)`](https://twitter.com/pawamoy)

#### **NOTES**
This man page is a perpetual work in progress. Expect some delays between
`pawamoy` releases and its documentation updates.
