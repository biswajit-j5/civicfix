# CivicFix: Secure self-hosting guide

CivicFix is open source. Anyone may fork or download the code and run their own instance, but **each installation must use its own Supabase project and its own hosting environment**. A GitHub fork must never be connected to the original owner's production Supabase project unless the owner intentionally grants that access.

## Isolation rule

- Your public GitHub repository contains application source code, not production access.
- Your live Netlify deployment uses your Supabase project URL and public anon/publishable key.
- A developer's copy must use a different Supabase project, their own Netlify site, and their own environment variables.
- Do not publish `.env`, `.env.local`, database passwords, Supabase service-role/secret keys, or messaging-provider secrets.
- The `VITE_*` variables are bundled into browser code. Only put the Supabase public anon/publishable key there, never a service-role key.

## Set up your own instance

1. Fork or clone this repository.
2. Create a new Supabase project that you own.
3. In that project's SQL Editor, run `supabase/schema.sql`.
4. Run `supabase/security-hardening.sql` in the same project's SQL Editor. Review the SQL before applying it to any existing production database; it changes `profiles` policies.
5. Create a local `.env.local` from `.env.example` and set your *own* Supabase project URL and public anon/publishable key:

   ```env
   VITE_SUPABASE_URL=https://YOUR-OWN-PROJECT-REF.supabase.co
   VITE_SUPABASE_ANON_KEY=YOUR_OWN_PUBLIC_ANON_OR_PUBLISHABLE_KEY
   ```

6. Install and run the app with `npm install` and `npm run dev`.
7. Register the account that should own the new installation. Confirm its email if confirmation is enabled.
8. In your own Supabase dashboard, open **Authentication → Users**, copy that account's UUID, then run the following in that same project's SQL Editor, replacing the placeholder with the UUID:

   ```sql
   update public.profiles
   set role = 'admin'
   where id = 'PUT-USER-UUID-HERE'
   returning id, full_name, role;
   ```

9. Deploy the copy to a new Netlify site and add that same installation's `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` as build environment variables. Redeploy after changing them.
10. Test with separate resident, pending-worker, approved-worker, and admin accounts.

## Why this does not make someone admin on the original site

The bootstrap SQL runs against the database selected in the Supabase dashboard. A developer who uses their own Supabase project promotes an account only in that project. They cannot promote themselves in the original owner's database without privileged access to that database. Never give out your Supabase dashboard credentials, database password, service-role key, or access to your production project to let someone self-host.

## Production security checks

- Public signup must not accept an `admin` role from the browser.
- Profile creation should assign `resident` by default; worker permissions should only be granted after approval.
- Keep Row Level Security enabled and verify the policies in `supabase/security-hardening.sql` are applied to the live project.
- Do not rely on hiding the admin page in React as the security boundary; database RLS and trusted server-side code must enforce permissions.
- Test that a resident cannot change their profile role, approve a worker, dispatch tasks, or modify administrative issue fields.
- The interactive demo role switch is local demo behavior only; it is not an administrator account in Supabase.
