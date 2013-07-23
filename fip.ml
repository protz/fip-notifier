type title = {
  mutable artist: string;
  mutable title: string;
  mutable album: string;
  mutable year: string;
  mutable cover_url: string;
}

type state = Before | Inside | After

let fetch_html () =
  let json = Network.get Config.json_url in
  let json = Yojson.Safe.from_string json in
  let html =
    match json with
    | `Assoc ["html", `String s; _] -> s
    | _ -> assert false
  in
  html

let _ =
  let current_entry = ref {
    artist = "";
    title = "";
    year = "";
    cover_url = "";
    album = ""
  } in
  while true do
    let html = fetch_html () in
    let lines = Util.split "\n" html in
    let entry = { artist = ""; title = ""; year = ""; cover_url = ""; album = "" } in
    let state = ref Before in
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

    if entry <> !current_entry then begin
      current_entry := entry;

      Printf.printf "artist=%s\ntitle=%s\nalbum=%s\nyear=%s\ncover_url=%s\n\n%!"
        entry.artist entry.title entry.album entry.year entry.cover_url;
    end else begin
      Printf.printf "no change\n\n%!";
    end;

    Unix.sleep 5
  done
