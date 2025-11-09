-- Create the pgflow pipeline
SELECT pgflow.create_flow('scrap_hackathon');
SELECT pgflow.add_step('scrap_hackathon', 'scrap');
SELECT pgflow.add_step('scrap_hackathon', 'extractMetadata', ARRAY['scrap']);
SELECT pgflow.add_step('scrap_hackathon', 'saveToDb', ARRAY['extractMetadata']);

-- Handle a new hackathon and push it to the queue
create or replace function private.handle_new_hackathon_apply_webscrap_batch()
returns trigger
language plpgsql
security definer
as $$
begin
  perform pgflow.start_flow('scrap_hackathon', (select jsonb_build_object('url', NEW.url)));

  return NEW;
end;
$$;

create or replace trigger on_handle_new_hackathon_apply_webscrap_batch
after insert on hackathons
  for each row
  execute function private.handle_new_hackathon_apply_webscrap_batch();

-- Keep edge worker ON
-- https://www.pgflow.dev/how-to/keep-workers-up/#smart-safety-net-solution
SELECT cron.schedule(
  'pgflow-watchdog--flow-scrap-hackathon',
  '10 seconds',
  $$
  WITH secret as (
      select decrypted_secret AS supabase_anon_key
      from vault.decrypted_secrets
      where name = 'supabase_anon_key'
  ),
  settings AS (
      select decrypted_secret AS supabase_url
      from vault.decrypted_secrets
      where name = 'supabase_url'
  )
  SELECT net.http_post(
    url := (select supabase_url from settings) || '/functions/v1/' || 'flow-scrap-hackathon',
    headers := jsonb_build_object('Authorization', 'Bearer ' || (select supabase_anon_key from secret))
  ) AS request_id
  WHERE (
    SELECT COUNT(DISTINCT worker_id) FROM pgflow.workers
    WHERE function_name = 'flow-scrap-hackathon'
      AND last_heartbeat_at > NOW() - make_interval(secs => 6)
  ) < 2;
  $$
);
