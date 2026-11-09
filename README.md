# Formline

A public project library and a Google-authenticated editor for projects with image gallery, model, presentation, and document steps. Projects are organized into sections and collections, themed individually, and can include video and public comments.

## Configure Supabase

The app uses Supabase Auth, Postgres, and Storage. Complete these steps before the gallery or editor can load shared projects:

1. Create a Supabase project and open its SQL Editor. Run [`supabase-setup.sql`](./supabase-setup.sql) to create or update project metadata, sections, collections, public comments, manager-only project/media policies, and the public and private media buckets. Re-run this script after pulling updates that change the schema.
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
2. Create sections at the library level, then select a section to create projects and collections. Collections group related projects, such as a Minihouse collection inside Engineering. Search projects by name or filter by section and collection. Managers can delete projects from their library cards; this also removes their comments and stored media. Empty sections and collections can be deleted from the selected filters; move projects out before deleting a section or collection that is in use.
3. Create **Process project**, **Document**, **Infinite diagram**, **3D node space**, or **Python sketch** projects. The Steps sidebar stays visible in process projects; add image gallery, model, presentation, or document steps in any order. Delete any step or page, including the last one; an empty project can be started again.
4. Gallery steps hold 3D image planes that can be moved, rotated, and scaled. Model steps support GLB, GLTF, OBJ, and STL uploads, optional X/Y/Z base rotation, and hotspots. Base rotation is shared between edit and view modes. Presentation pages default to 15 × 7 units and documents to 10 × 20 units; adjust either dimension from 5 to 30 in Page size.
5. Infinite diagrams support zoomable 2D and navigable 3D node spaces. Add and search nodes, edit their notes/colors, link them to project steps, and create multiple directed connections. In 3D, each numeric connection value (0.1–10, default 1) controls its relative pull and target spacing; a gently damped layout groups connected nodes. Nodes are checked before overlapping arrows, so connections do not prevent selecting them.
6. Python sketch projects include a **Functions & guide** tab with examples and language reference. The safe, Python-style sketch language supports variables, arrays and indexing, named drawing arguments, user-defined functions and returns, `if`/`else`, bounded `for`/`while` loops, imports between up to 20 project files, and math helpers including trigonometry, `sqrt`, `pow`, `factorial`, `hypot`, `lerp`, `clamp`, `map_range`, `mean`, `median`, `dot`, `gcd`, and `is_prime`. Its canvas API includes shapes, transforms, reusable paths and curves, exact single or batched pixel writes, pixel reads, opacity and line styles, and pointer or focused-key input. Resize the canvas, export it as PNG, and choose 15, 30, or 60 fps from the sketch workbench. For animation, end `main.py` with a top-level `while True:` and choose **Run continuously**; the loop runs one frame at a time with persistent variables and canvas contents, and can be paused, resumed, or stopped. Pauses do not advance sketch time. `seed_random(seed)` makes random sequences repeatable. Each animation frame is capped at 1,000 statements; one-shot runs allow 3,000. Canvas dimensions are limited to 1,600 × 1,000 and 1.5 million pixels; `pixel_batch` writes up to 1,000 points per call. Create helper files beside `main.py` and import functions with `from helpers import draw_star`. The interpreter does not execute arbitrary Python, JavaScript, access the page DOM, or perform network/file access. A project is limited to 50,000 characters and 500 lines; imports cannot be circular.
7. Documents have a wide editing canvas, word/character counts, 14 text sizes (8–48 px), code blocks, dividers (toolbar or type `---` and press Enter), quotes, lists, and keyboard formatting shortcuts. Select text before choosing its size. Add editable text overlays and draw lines, rectangles, ellipses, or polygons with configurable stroke, width, and fill on steps that support media. Use Project appearance settings for per-project accent and canvas colors.
8. Check **Save in my private library** when creating a project to keep it out of public browsing and search. Private project rows are protected by database row-level security, and their uploads use a private storage bucket with manager-only access and expiring signed URLs. The manager-only **Private** filter is not a public section.
9. Add optional MP4, WebM, or Ogg video up to 100 MB to an item. Public reviewers can comment without signing in, as Anonymous or using a name they enter. The manager can remove comments; public posting can attract spam, so add CAPTCHA/rate limiting before a high-traffic launch.
10. Editor shortcuts are customizable in Editor Settings. Documents and text overlays use standard browser `contenteditable` elements, which Grammarly and similar extensions generally recognize, though extension behavior depends on the browser and extension settings. Changes and media are shared via Supabase across devices.

## Deploy with GitHub Pages

This is a static HTML site and can be hosted directly from GitHub without a separate hosting service:

1. Push the project files, including `index.html`, to a GitHub repository.
2. In the repository, open **Settings → Pages**. Under **Build and deployment**, choose **Deploy from a branch**, select the branch containing the site (usually `main`) and the `/(root)` folder, then save.
3. Wait for the deployment. The site URL is usually `https://<username>.github.io/<repository>/`.
4. In Supabase **Authentication → URL Configuration**, set the Site URL to the deployed site URL and add that URL to the allowed redirect URLs. Keep your local URL there too if you use local development. In Google Cloud, keep the Supabase callback URL from the Supabase Google provider settings as an authorized redirect URI.

GitHub Pages hosts the website files only. Supabase is still required for shared projects, manager sign-in, comments, and uploaded media. The frontend imports Three.js and Supabase JS from public CDNs, so internet access is required.
