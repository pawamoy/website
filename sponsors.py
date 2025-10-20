import json
import os
from contextlib import nullcontext
from itertools import groupby
from pathlib import Path

from insiders import GitHub, Polar, Sponsors, Sponsorship


GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
POLAR_TOKEN = os.getenv("POLAR_TOKEN")
TIERS = (1000, 500, 200, 100)
LOGO_DATA = json.loads(Path("sponsors-logo.json").read_text(encoding="utf8"))


def get_tier(sponsorship: Sponsorship) -> int:
    for amount in TIERS:
        if sponsorship.amount >= amount:
            return amount
    return 0


def html(sponsorship: Sponsorship) -> str:
    if sponsorship.account.name in LOGO_DATA:
        name = LOGO_DATA[sponsorship.account.name]["name"]
        url = LOGO_DATA[sponsorship.account.name]["url"]
        image = LOGO_DATA[sponsorship.account.name]["logo"]
        height = LOGO_DATA[sponsorship.account.name]["height"]
        style = ""
    else:
        name = sponsorship.account.name
        url = sponsorship.account.url
        image = sponsorship.account.image
        height = None
        style = "border-radius: 100%;"
    if not name or not url or not image:
        return ""
    height = height or 32
    if isinstance(image, str):
        return f'<a href="{url}"><img alt="{name}" src="{image}" style="height: {height}px; {style}"></a>'
    return (
        f'<a href="{url}"><picture>'
        f'<source media="(prefers-color-scheme: light)" srcset="{image[0]}">'
        f'<source media="(prefers-color-scheme: dark)" srcset="{image[1]}">'
        f'<img alt="{name}" src="{image[0]}" style="height: {height}px; {style}"></picture>'
        f"</a>"
    )


def main() -> int:
    github_context = GitHub(GITHUB_TOKEN) if GITHUB_TOKEN else nullcontext()
    polar_context = Polar(POLAR_TOKEN) if POLAR_TOKEN else nullcontext()
    with github_context as github, polar_context as polar:
        sponsors = Sponsors()
        if github:
            sponsors.merge(github.get_sponsors(exclude_private=False))
        if polar:
            sponsors.merge(polar.get_sponsors(exclude_private=False))

    if not sponsors.sponsorships:
        return 0

    # Sort (sponsorship, tier) by tier descending, then by sponsorship creation date ascending.
    sorted_sponsorships = sorted(
        ((sp, get_tier(sp)) for sp in sponsors.sponsorships),
        key=lambda x: (-x[1], x[0].created),
    )

    with Path("docs", "sponsors.txt").open("w", encoding="utf8") as sponsors:
        private = 0
        print('\n<div id="premium-sponsors" style="text-align: center;">', file=sponsors)

        # Group by tier.
        for tier, group in groupby(sorted_sponsorships, key=lambda x: x[1]):
            newline = "<br>"
            if tier == 1000:
                print('\n<div id="platinum-sponsors"><b>Platinum sponsors</b><p>', file=sponsors)
            elif tier == 500:
                print('\n<div id="gold-sponsors"><b>Gold sponsors</b><p>', file=sponsors)
            elif tier == 200:
                print('\n<div id="silver-sponsors"><b>Silver sponsors</b><p>', file=sponsors)
            elif tier == 100:
                print('\n<div id="bronze-sponsors"><b>Bronze sponsors</b><p>', file=sponsors)
            else:
                print('</div>\n\n---\n\n<div id="sponsors"><p>', file=sponsors)
                newline = ""
            for sponsorship, _ in group:
                if sponsorship.private and sponsorship.account.name not in LOGO_DATA:
                    private += 1
                    continue
                print(html(sponsorship) + newline, file=sponsors)
            print("</p></div>", file=sponsors)
        if private:
            print(f"\n\n*And {private} more private sponsor(s).*", file=sponsors)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())