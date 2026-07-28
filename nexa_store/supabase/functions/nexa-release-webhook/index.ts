import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface ReleasePayload {
  package_name: string;
  version: string;
  download_url: string;
  sha256: string;
  app_name: string;
  has_patch?: boolean;
  patch_url?: string;
  patch_sha256?: string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload = (await req.json()) as ReleasePayload;
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, serviceKey);

    const row = {
      name: payload.app_name,
      package_name: payload.package_name,
      version: payload.version.replace(/^v/i, ""),
      download_url: payload.download_url,
      sha256: payload.sha256,
      patch_url: payload.has_patch ? payload.patch_url ?? null : null,
      patch_sha256: payload.has_patch ? payload.patch_sha256 ?? null : null,
    };

    const { data: existing } = await supabase
      .from("apps")
      .select("id")
      .eq("package_name", payload.package_name)
      .maybeSingle();

    if (existing?.id) {
      await supabase.from("apps").update(row).eq("id", existing.id);
    } else {
      await supabase.from("apps").insert(row);
    }

    return new Response(JSON.stringify({ ok: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ ok: false, error: String(error) }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
