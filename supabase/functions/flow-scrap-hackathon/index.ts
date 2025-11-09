import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { EdgeWorker } from "jsr:@pgflow/edge-worker";

import { ScrapHackathonFlow } from "../_flows/scrap_hackathon.ts";

EdgeWorker.start(ScrapHackathonFlow);
