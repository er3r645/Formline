# Formline

A public project library and a Google-authenticated editor for projects with image gallery, model, presentation, and document steps. Projects are organized into sections and collections, themed individually, and can include video and public comments.

## Configure Supabase

The app uses Supabase Auth, Postgres, and Storage. Complete these steps before the gallery or editor can load shared projects:

1. Create a Supabase project and open its SQL Editor. Run [`supabase-setup.sql`](./supabase-setup.sql) to create or update project metadata, sections, collections, public comments, manager-only project/media policies, and the public media bucket. Re-run this script after pulling updates that change the schema.
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
3. New projects start empty. The **Steps** sidebar stays visible in edit mode; use **Add a step** to choose **Image gallery**, **Model**, **Presentation**, or **Document**. Delete any step or page with its delete control; an empty project can be given a new first step. Gallery steps hold 3D image planes that can be moved, rotated, and scaled in the editor; in present mode, separate image arrows show one gallery image at a time. Model steps use the 3D and media tools and have optional X/Y/Z base rotation controls, useful for orienting models such as sideways STL files; the saved orientation is shared between edit and view modes. Presentation steps support slide images and hotspots; Document steps are rich-text pages. Presentation pages default to 15 × 7 units and documents to 10 × 20 units; adjust either dimension from 5 to 30 in Page size. For proportion reference, legal paper is about 8.5 × 14 inches. Add steps in any order to combine formats in one project. Existing model, presentation, gallery, and document projects remain supported.
4. Add editable text overlays and draw lines, rectangles, ellipses, or polygons with configurable stroke, width, and fill on steps that support media. Documents have their own rich-text editor. Use Project appearance settings for per-project accent and canvas colors.
5. Add optional MP4, WebM, or Ogg video up to 100 MB to an item. Public reviewers can comment without signing in, as Anonymous or using a name they enter. The manager can remove comments; public posting can attract spam, so add CAPTCHA/rate limiting before a high-traffic launch.
6. Editor shortcuts are customizable in Editor Settings. Documents and text overlays use standard browser `contenteditable` elements, which Grammarly and similar extensions generally recognize, though extension behavior depends on the browser and extension settings. Changes and media are shared via Supabase across devices.

## Deploy with GitHub Pages

This is a static HTML site and can be hosted directly from GitHub without a separate hosting service:

1. Push the project files, including `index.html`, to a GitHub repository.
2. In the repository, open **Settings → Pages**. Under **Build and deployment**, choose **Deploy from a branch**, select the branch containing the site (usually `main`) and the `/(root)` folder, then save.
3. Wait for the deployment. The site URL is usually `https://<username>.github.io/<repository>/`.
4. In Supabase **Authentication → URL Configuration**, set the Site URL to the deployed site URL and add that URL to the allowed redirect URLs. Keep your local URL there too if you use local development. In Google Cloud, keep the Supabase callback URL from the Supabase Google provider settings as an authorized redirect URI.

GitHub Pages hosts the website files only. Supabase is still required for shared projects, manager sign-in, comments, and uploaded media. The frontend imports Three.js and Supabase JS from public CDNs, so internet access is required.
