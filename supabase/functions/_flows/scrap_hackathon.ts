import { createClient } from "jsr:@supabase/supabase-js";
import { Flow } from "npm:@pgflow/dsl";
import { scrapHackathonWebsite } from "../_tasks/scrapHackathonWebsite.ts";
import { extractHackathonPage } from "../_tasks/extractHackathonPage.ts";

import { Database } from "@what-to-hack/shared/types/database.ts";

type Input = {
  url: string;
};

export const ScrapHackathonFlow = new Flow<Input>({
  slug: "scrap_hackathon",
})
  .step(
    { slug: "scrap" },
    ({ run }) => scrapHackathonWebsite(run.url),
  )
  .step(
    { slug: "extractMetadata", dependsOn: ["scrap"] },
    async ({ scrap }) => await extractHackathonPage(scrap.content),
  )
  .step(
    { slug: "saveToDb", dependsOn: ["extractMetadata"] },
    async ({ run, extractMetadata }) => {
      const db = createClient<Database>(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_ANON_KEY")!,
      );

      const { error: saveHackathonError } = await db.from("hackathons").update({
        name: extractMetadata.name,
        description: extractMetadata.description,
        host_company: extractMetadata.host_company,
        sponsors: extractMetadata.sponsors,
        location: extractMetadata.location,
        start_date: extractMetadata.start_date?.toString(),
        end_date: extractMetadata.end_date?.toString(),
      })
        .eq("url", run.url);

      if (saveHackathonError) {
        console.error(saveHackathonError);
        throw saveHackathonError;
      }
    },
  );
