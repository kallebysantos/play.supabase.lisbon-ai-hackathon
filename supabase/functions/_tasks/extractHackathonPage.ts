import { z } from "jsr:@zod/zod";
import { generateObject } from "npm:ai@5.0.56";
import { createOpenAICompatible } from "npm:@ai-sdk/openai-compatible@1.0.19";

export const ExtractedHackathonSchema = z.object({
  name: z.string(),
  description: z.string(),
  host_company: z.string(),
  sponsors: z.array(z.string()),
  location: z.string(),
  start_date: z.json(),
  end_date: z.json(),
});

export type ExtractedHackathonType = z.infer<typeof ExtractedHackathonSchema>;

const aiProvider = createOpenAICompatible({
  name: "supabase-ai-provider",
  baseURL: Deno.env.get("OPENAI_URL") || "https://api.openai.com/v1",
  apiKey: Deno.env.get("OPENAI_API_KEY"),
});

const aiModel = Deno.env.get("OPENAI_MODEL") || "gpt-3.5-turbo";

export const SYSTEM_PROMPT = `#CONTEXT:
- You're a digital assistant of What-To-Hack Hackathon searching app.
- Your main goal is grab the hackathon website page and extract how much information you can.
- Return it in structued JSON format:
{
  name: z.string(),
  description: z.string(),
  host_company: z.string(),
  sponsors: z.array(z.string()),
  location: z.string(),
  start_date: z.json(),
  end_date: z.json(),
}
`;

export async function extractHackathonPage(
  rawPageContent: string,
): Promise<ExtractedHackathonType> {
  const result = await generateObject({
    model: aiProvider(aiModel),
    schemaName: "hackathon-object",
    schemaDescription: "A hackathon structued object",
    schema: ExtractedHackathonSchema,
    system: SYSTEM_PROMPT,
    prompt: rawPageContent,
    temperature: 0.3,
    maxOutputTokens: 768,
    maxRetries: 3,
    mode: "tool",
  });

  return result.object as ExtractedHackathonType;
}
