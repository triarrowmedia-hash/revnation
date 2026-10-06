# Rev Nation Jaipur — Supabase Setup Guide

Everything the **live site** (`index.html`) and the **admin panel** (`studio-gate-88.html`) need from Supabase. Takes ~10 minutes.

## 1. Create the Supabase project

1. Go to [supabase.com](https://supabase.com) → **New project**.
2. Pick any name/region, set a database password, wait for provisioning.

## 2. Run the SQL

1. In the Supabase dashboard → **SQL Editor** → **New query**.
2. Paste the entire contents of [`supabase-schema-v2.sql`](supabase-schema-v2.sql) → **Run**.

This single file creates:

| What | Name | Who can do what |
|---|---|---|
| Tables | `leads`, `projects`, `services`, `testimonials`, `stats`, `site_media`, `frame_sequences` | Visitors read published content + submit leads; signed-in admin can do everything |
| Storage buckets | `project-images`, `site-assets`, `frame-sequences` | Public read, admin-only write |
| Seed content | 4 stats, 4 services, 4 testimonials | Matches the site's built-in fallback so nothing looks empty |

Security note: Row Level Security is enabled on every table. The **anon key** in `config.js` is safe to expose publicly — it can only read published rows and insert leads. Never put the `service_role` key in any file.

## 3. Paste your keys

Open `config.js` and replace the two placeholders:

```js
window.REV_NATION_CONFIG = {
  SUPABASE_URL: "https://YOUR-PROJECT.supabase.co",   // Project Settings → API → Project URL
  SUPABASE_ANON_KEY: "eyJhbG..."                       // Project Settings → API → anon public
};
```

## 4. Create your admin login

1. Dashboard → **Authentication** → **Users** → **Add user**.
2. Give it an email and password (this is *you*, the studio admin — not a site visitor).
3. Open `/studio-gate-88.html` and sign in.

## 5. What the admin panel controls

| Tab | Effect on the live site |
|---|---|
| Leads | Booking form submissions land here (mark Contacted / Closed) |
| Projects / Builds | Cards in the "Studio Log" gallery |
| Services | The "What We Do" cards (photos replace the placeholder images) |
| Testimonials | The review cards |
| Stats | The odometer counters |
| Site Media & Video | Hero video, hero poster, Before/After slider images |
| Frame Sequences | Uploaded image sequences (for future scroll scenes) |

## Done

Deploy the folder as-is (GitHub Pages / Netlify / any static host). No build step.
