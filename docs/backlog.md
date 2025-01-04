---
hide:
- navigation
---

# Backlog management

This page describes how I manage my backlog of issues on GitHub. This information is useful for both regular users and sponsors, since you'll learn how to give more weight to the issues you're interested in.

## Issue overview

I maintain many different projects on GitHub, each having its own issue tracker. GitHub provides an [/issues page](https://github.com/issues) which lets you fetch all issues across your user account and your organization accounts, for example with the query `is:open is:issue user:pawamoy org:mkdocstrings`. It then shows all found issues with pagination of (I believe) 30 items per page, which is more than enough to start working on issues. You can sort by upvotes to prioritize the issues that the most users are interested in. The final query can look like this: `is:open is:issue user:pawamoy org:mkdocstrings sort:reactions-+1-desc is:public`.

Unfortunately, there are a few limitations with this system.

- On GitHub you can upvote your own issues, giving you an unfair advantage over those who don't.
- Sponsors upvotes should have more weight according to their sponsorship amount (per month). This kind of sorting is not possible through GitHub webpages.
- Some kind of issues should always be prioritized over other kinds, for example bugs over features. Once again, you cannot sort based on labels on GitHub webpages.

To overcome these limitations, I developed a tool that lets me fetch issues from GitHub, as well as sponsorship data from platforms I support ([GitHub Sponsors] and [Polar] currently), that I can then sort according to my own, tailored criteria. It works in the terminal and displays a table of issues.

![backlog](assets/backlog.png)

The columns show:

- the index of the issue in the backlog
- the issue identifier (account/repository#number)
- the author of the issue
- the labels (as emojis)
- the funding amount (more on this below, hidden here for privacy reasons)
- the boost amount (more on this below)
- the number of upvotes
- the title of the issue

## Sponsorship amount

The sponsorship amount (or funding amount) is the sum of all distinct sponsorships attached to the author and upvoters of the issue. Lets unpack this.

On GitHub, you can sponsor using an organization account. Since it's not possible to add organizations as members of teams (my current way of giving access to private projects to sponsors), I ask organization sponsors to provide a list of usernames that should be granted access to private projects. These usernames are listed as members of this organization in my local configuration data.

Since their organization is sponsoring me, they must benefit from the voting power matching the organization sponsorship amount. The sponsorship and the users are therefore "linked" together. That lets me know, for a given user, which sponsorships they benefit from. A single user could benefit from multiple sponsorships, as they could create one themselves, and be a member of several organization that created sponsorships.

For a given issue, I therefore build the set of distinct sponsorships (literally using a Python `set`) from the issue author's linked sponsorships, and each of the issue upvoters' linked sponsorships. We give upvoters the same weight opportunity as the author, because a sponsor won't always be able to *create* the issues, and instead only be able to *upvote* them to show their interest.

**Sponsors, use your voting power!** :smile:

NOTE: **Organization members vs. users and their plus-one**
I have allowed some users sponsoring for $50 or more, **using their own account**, to provide additional usernames who are granted access to the private projects. While this seems only fair to me, please note that this has the disadvantage that these additional users cannot be listed as part of an organization, and therefore won't benefit from the same voting power as the sponsoring user. This limitation will be lifted in the future. See [Reviewing beneficiaries](#reviewing-beneficiaries).

## Boosts

In 2024, I introduced the opportunity for users to "boost" issues, by making pledges via [Polar]. Pledges start at a minimum of $5, and the sum of pledges must rise up to $30 for an issue to be boosted. It means that issues can be boosted by single individuals/organizations pledging $30 or more, or by 6 individuals/organizations pledging each $5. I figured $30 was a good balance given the variability in issues' difficulty of resolution, and that $5 was low enough to be affordable, and high enough to not require dozens of participants.

[View all issues with pledges](https://polar.sh/pawamoy/issues?sort=most_funded&badged=1){ .md-button .md-button--primary }

Boosted issues will be prioritized over non-boosted ones, but not over "funded" ones (issues created or upvoted by users benefitting from monthly sponsorships). If you already fund my projects through a monthly sponsorship of $50, you don't need to boost issues. The reason is that monthly sponsorships are much more reliable as income, and in a society where reliable, monthly income is extremely important, I want to encourage monthly sponsorships over one-time donations or payments. Boosts were initially setup because some organizations can only make one-time payments (for various reasons), and they still wanted to have the ability to accelerate resolution of issues in exchange for financial compensation. Who am I to say no to their dollars? :smile: More seriously, even if monthly sponsorships are preferred, one-time payments are still very much appreciated.

Issues with an `insiders` label will still be released as [Insiders](insiders.md) features first, whether they are boosted or not.

We receive the pledges only once the issue is completed, and confirmed by you (within a period of 7 days).

The boost system is still in experimental phase and might be re-configured differently in the future. Your feedback is welcome! You can send it at <insiders@pawamoy.fr>.

## Sorting criteria

As of writing, here is the list of criteria used to sort the backlog, applied in order:

1. **Issues labeled as `bug` (🐞).** Bugs are given the highest priority. I don't think I need to elaborate why.
2. **Issues labeled as `unconfirmed` (❔).** It's important to triage issues quickly to identify bugs and documentation issues.
3. **Issues labeled as `docs` (📘).** Incorrect documentation is worse than no documentation.
4. **Issues with a minimum total sponsorship amount of 50 (💖).** Issue priorization is a benefit of sponsorship tiers starting at $50 per month. Sponsors with lower tiers will have to combine their effort to reach 50 together. Both the author and the upvoters' sponsorships are taken into account, see [Sponsorship amount](#sponsorship-amount).
5. **Issues with a minimum boost pledge of $30 (💲).** The boost system, see [Boosts](#boosts).
6. **Issues with a minimum of 2 upvotes (👍).** Since one can upvote their own issue, we raise the bar to 2 upvotes.
7. **Issues labeled as `insiders` (🔒).** These issues are candidate for [Insiders](insiders.md) features (✨=feature). Insiders is generally what gives incentive to users to sponsor me, so it's only natural that I prioritize these features. Non-insiders features come after Insiders ones.
8. **Issues from the @mkdocstrings namespace.** Most of my sponsors are mainly interested in my work within mkdocstrings and its ecosystem, so I prioritize these over issues within my own namespace (@pawamoy).
9. **Oldest issues first.** First in, first out. It's ticketing system after all.

Although I generally follow this ordering, **I reserve the right to diverge from it**. This goes both ways. An issue with 0 funding and 0 upvotes could become top-priority if it will facilitate maintenance or prevent regressions. A bug I noticed could be skipped if nobody experiences it or if it happens in an old, unused project. A docs-related issue could be skipped if it's about adding (not fixing) non-critical information.

## Privacy

Since sponsors on [GitHub Sponsors] can create **private** sponsorships, there is a privacy concern with sharing the actual backlog, as it would indicate that users are sponsoring me, and for how much. **It means that I cannot share the real backlog publicly.** The backlog samples I share are always built **using public data only**, which means you shouldn't rely on them.

## Reviewing beneficiaries

When an individual sponsors me, things are easy: if they selected a tier equal to or higher than $10 per month, they get access to Insiders. In any case, they get the voting power matching the tier they selected.

When an organization sponsors me, things get a bit more complex. If they selected a tier equal to or higher than $10 per month, the organization members must get access to Insiders. **But I cannot automate that.**

First, because it's not possible to add organizations to other organizations or teams. Second, because users could easily "game the system": sponsor as an organization for $10, and invite all you friends as members so they enjoy it too. Even if I set limits, like one user per $10 ($50, 5 users), what if an organization has more users than its accepted limit? Should I sort them alphabetically? That seems rather arbitrary and not very safe: if a user changes their name, they could take the place of a fellow member, whose access would then be revoked. Third, because users are not always listed as organization members. And when they are, the information is not always public.

So instead of fetching organization members automatically, organizations must provide a list of users that will get access to Insiders. I feed that list to my automated system, and it handles granting/revoking accesses. But... what about voting power? Shouldn't we give the voting power to *all* the members of an organization, not just the ones who get access to the private projects? The organization might even just grant access to a bot account. Yet the actual members should be able to vote with the weight of their organization sponsorship. Also, what happens if a user leaves an organization? Their access should be revoked, and their voting power reset. But surely, organizations won't remember to send me an email to let me know a user has left. How do I help myself tracking this? 

So I do fetch organization members automatically! But I only *aggregate* this data to the explicit lists of users sent by organizations, for two purposes:

1. Verify organization membership. If an organization asks me to grant access to a user, I grant them access, but I verify whether they're actually listed as an organization member. With this information, I can periodically review whether they're still part of the organization or not. If not, I can reach out and ask if their Insiders access should be revoked.
2. Give voting power to verified members.

For now, my system only allows explicit lists of beneficiaries *for organization accounts*. That's the reason why beneficiaries of individual accounts cannot be granted voting power matching their linked sponsorship. I will lift this limitation in the future. The organization/individual distinction is just an artifact of GitHub's architecture, so it must not affect other sponsorship platforms.

TIP: **List your organization members publicly, if possible.**
By having your organization members visible through GitHub's API, you facilitate my ability to review beneficiaries, and you enable automatic voting power matching your sponsorship amount for all your organization members.

[GitHub Sponsors]: https://github.com/sponsors/
[Polar]: https://polar.sh
