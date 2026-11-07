# Formline

A public project gallery and a Google-authenticated editor for 3D, image-gallery, and mixed process presentations.

## Configure Supabase

The app uses Supabase Auth, Postgres, and Storage. Complete these steps before the gallery or editor can load shared projects:

1. Create a Supabase project and open its SQL Editor. Run [`supabase-setup.sql`](./supabase-setup.sql) to create the public project table, manager-only row policies, and public media bucket with manager-only uploads.
2. In **Project Settings → API**, copy the Project URL and the publishable/anon key into [`supabase-config.js`](./supabase-config.js). These client-side values are public; never put a service-role key in the website.
3. In **Authentication → Providers → Google**, enable Google and add the OAuth client ID and client secret from Google Cloud. In Google Cloud, add the Supabase callback URL shown by the provider settings as an authorized redirect URI.
4. In **Authentication → URL Configuration**, set the Site URL to the deployed website origin and add its URL (and `http://localhost:8000` during development) to the allowed redirect URLs.
5. Serve the app over HTTP. For local development:

   ```sh
   python3 -m http.server 8000
   ```

   Open `http://localhost:8000/`.

The only editor account is `er275050@gmail.com`. Google sign-in is checked in the UI and independently enforced by Supabase row-level and storage policies. The project gallery is public and projects are ordered by creation time. `viewer.html` opens the gallery; selecting a project opens its presentation. A direct review link can use `index.html?project=<project-id>&present=1`.

## Create and review projects

1. Choose **Enter as manager** and sign in with the allowed Google account.
2. Create a project in the gallery or open an existing one to edit its title and timeline.
3. Add a 3D model (GLB, GLTF with embedded assets, OBJ, or STL), images, or both to each step.
4. Drag images on the stage; select one to adjust its size and rotation. Hotspots anchored to a 3D model can also include an image.
5. Return to the public gallery to open the project as a reviewer. Changes and media are shared via Supabase across devices.

The frontend imports Three.js and Supabase JS from public CDNs, so internet access is required.
