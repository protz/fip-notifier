open Title

type state = Before | Inside | After

(* Fetch the JSON file from FIP's website, and then extract the raw HTML from it. *)
let fetch_html () =
  (* The JSON has a very specific structure, so it's easy to extract the html
   * bits from it. *)
  let json = Network.get Config.json_url in
  let json = Yojson.Safe.from_string json in
  let html =
    match json with
    | `Assoc ["html", `String s; _] -> s
    | _ -> assert false
  in
  html
;;

let _ =
  (* We keep a current state, and try to refresh it every five seconds. We use
   * structural comparison on entries to determine whether something changed or
   * not. *)
  let current_entry = ref {
    artist = "";
    title = "";
    year = "";
    cover_url = "";
    album = ""
  } in
  let current_cover = ref "" in

  while true do try
    (* The entry that we're about to build. *)
    let entry = { artist = ""; title = ""; year = ""; cover_url = ""; album = "" } in
    (* We have a state machine. We're either before the current entry, inside
     * it, or we've gone past it. *)
    let state = ref Before in

    (* Fetch the html, split along the lines. *)
    let html = fetch_html () in
    let lines = Util.split "\n" html in

    (* Regexp-foo to fill in the current entry. *)
    List.iter (fun line ->
      if Util.matches "class='direct-current'" line then
        state := Inside;

      if Util.matches_div "artiste" line && !state = Inside then
        entry.artist <- Util.get_match line;
      if Util.matches_div "titre" line && !state = Inside then
        entry.title <- Util.get_match line;
      if Util.matches_div "album" line && !state = Inside then
        entry.album <- Util.get_match line;
      if Util.matches_div "annee" line && !state = Inside then
        entry.year <- Util.get_match line;
      if Util.matches "<img src=\"\\([^\"]+\\)" line && !state = Inside then
        entry.cover_url <- Util.get_match line;

      if Util.matches "class='direct-next'" line then
        state := After;
    ) lines;


    (* Did the current song change? *)
    if entry <> !current_entry then begin
      (* Remove the old cover if needed. *)
      if !current_cover <> "" then begin
        try Unix.unlink !current_cover with _ -> ();
      end;

      (* We have our new entry. *)
      current_entry := entry;

      (* Fix and download the new cover. *)
      let cover_url =
        if String.length entry.cover_url > 0 && entry.cover_url.[0] = '/' then
          Config.fip_root ^ entry.cover_url
        else
          entry.cover_url
      in
      let file = Network.save cover_url in
      current_cover := file;

      (* Emit the actual notification. *)
      Notify.notify entry file;

      (* Debug. *)
      Printf.printf "artist=%s\ntitle=%s\nalbum=%s\nyear=%s\ncover_url=%s\n\n%!"
        entry.artist entry.title entry.album entry.year entry.cover_url;
    end else begin
      (* Debug. *)
      Printf.printf "no change\n\n%!";
    end;

    Unix.sleep 5

  with
  | Curl.CurlException _
  | Yojson.Json_error _ ->
      ()
  done
;;
