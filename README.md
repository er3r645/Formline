# Formline

A public project library and a Google-authenticated editor for model walkthroughs, slide presentations, and image galleries. Projects can be grouped into named sections, themed individually, include video, and collect public comments.

## Configure Supabase

The app uses Supabase Auth, Postgres, and Storage. Complete these steps before the gallery or editor can load shared projects:

1. Create a Supabase project and open its SQL Editor. Run [`supabase-setup.sql`](./supabase-setup.sql) to create or update the project table, public comments table, manager-only project/media policies, and public media bucket. Re-run this script after pulling updates that change the schema.
2. In **Project Settings → API**, copy the Project URL and the publishable/anon key into [`supabase-config.js`](./supabase-config.js). These client-side values are public; never put a service-role key in the website.
3. In **Authentication → Providers → Google**, enable Google and add the OAuth client ID and client secret from Google Cloud. In Google Cloud, add the Supabase callback URL shown by the provider settings as an authorized redirect URI.
4. In **Authentication → URL Configuration**, set the Site URL to the deployed website origin and add its URL (and your local development URL, such as `http://localhost:8000/`) to the allowed redirect URLs.
5. Serve the app over HTTP. For local development:

   ```sh
   python3 -m http.server 8000
   ```

   Open `http://localhost:8000/`.

The only editor account is `er275050@gmail.com`. Google sign-in is checked in the UI and independently enforced by Supabase row-level and storage policies. The project library is public and projects are ordered by creation time. `viewer.html` opens the library; selecting a project opens its review view. A direct review link can use `index.html?project=<project-id>&present=1`.

## Create and review projects

1. Choose **Enter as manager** and sign in with the allowed Google account.
2. Create a Model, Presentation, or Gallery project and assign it to a section such as Engineering, Art, or Music. Search by project name or filter by section in the public library.
3. Model projects are step-by-step; presentations are slide-by-slide with editable text, full-frame images, and slide hotspots; galleries advance image-by-image with freely arranged images.
4. Add optional MP4, WebM, or Ogg video up to 100 MB to an item. Use Project appearance settings to choose its accent and canvas colors.
5. Reviewers can comment without signing in, using Anonymous or a name they enter. Comments are public and the manager can remove them; public posting can attract spam, so add CAPTCHA/rate limiting before a high-traffic launch.
6. Changes and media are shared via Supabase across devices.

## Deploy with Netlify

Connect the GitHub repository to Netlify. This is a static HTML site: leave the build command empty and set the publish directory to `.` (the repository root, where `index.html` lives). To test a branch without changing production, enable branch deploys in Netlify. Merge to the configured production branch to publish production changes. Add the deployed HTTPS origin to Google OAuth's authorized JavaScript origins and to Supabase's Site URL and allowed redirect URLs.

The frontend imports Three.js and Supabase JS from public CDNs, so internet access is required.
