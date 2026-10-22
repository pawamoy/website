async function readBlogPage(url) {
  const response = await fetch(url, { cache: "no-cache" });
  if (!response.ok) throw new Error(`Blog request failed: ${response.status}`);
  return {
    document: new DOMParser().parseFromString(await response.text(), "text/html"),
    url: response.url,
  };
}

function readPosts(page) {
  return [...page.document.querySelectorAll(".md-post--excerpt")].map(post => {
    const title = post.querySelector(".md-post__content h2 > a.toclink");
    const date = post.querySelector(".md-post__meta time");
    return {
      title: title.textContent.trim(),
      url: new URL(title.getAttribute("href"), page.url).href,
      year: date.getAttribute("datetime").slice(0, 4),
    };
  });
}

async function updatePostNavigation() {
  const config = document.getElementById("__config");
  if (!config) return;
  const homeUrl = new URL(`${JSON.parse(config.textContent).base}/`, window.location.href);

  try {
    // Native excerpts preserve the blog plugin's ordering and preview-only drafts.
    const home = await readBlogPage(homeUrl);
    const posts = readPosts(home);
    if (!posts.length) return;

    for (const link of document.querySelectorAll(".md-tabs__link, .md-nav__link")) {
      if (link.hash === "#posts" && link.pathname === homeUrl.pathname) {
        link.href = posts[0].url;
      }
    }

    const metadata = document.querySelector(".md-sidebar--post .md-post__meta");
    if (!metadata || metadata.parentElement.querySelector(".md-post__index")) return;

    const pageUrls = new Set([...home.document.querySelectorAll(".md-pagination a")]
      .map(link => new URL(link.getAttribute("href"), home.url).href));
    const pages = await Promise.all([...pageUrls].map(readBlogPage));
    posts.push(...pages.flatMap(readPosts));

    const years = new Map();
    for (const post of posts) {
      if (!years.has(post.year)) years.set(post.year, []);
      years.get(post.year).push(post);
    }

    const navigation = document.createElement("nav");
    navigation.className = "md-post__index md-nav";
    navigation.setAttribute("aria-label", "Blog posts");

    for (const [label, posts] of [...years].sort(([a], [b]) => b.localeCompare(a))) {
      const year = document.createElement("div");
      year.className = "md-post__year";
      year.textContent = label;
      const list = document.createElement("ul");
      list.className = "md-nav__list";

      for (const post of posts) {
        const item = document.createElement("li");
        item.className = "md-nav__item";
        const link = document.createElement("a");
        link.className = "md-nav__link";
        link.href = post.url;
        link.textContent = post.title;
        if (new URL(link.href).pathname === window.location.pathname) {
          link.classList.add("md-nav__link--active");
          link.setAttribute("aria-current", "page");
        }
        item.append(link);
        list.append(item);
      }

      navigation.append(year, list);
    }

    if (metadata.isConnected) metadata.after(navigation);
  } catch (error) {
    console.warn("Could not load blog navigation.", error);
  }
}

if (typeof document$ !== "undefined") {
  document$.subscribe(updatePostNavigation);
} else {
  updatePostNavigation();
}
