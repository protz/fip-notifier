(* [notify title img] displays a notification using libnotify for [title], using
 * the path specified in [img] for the image. *)
let notify (title: Title.t) (img: string): unit =
  let open Title in
  (* Double-fork so that we don't create zombies. *)
  if Unix.fork () = 0 then
    if Unix.fork () <> 0 then
      exit 0
    else
      Unix.execv Config.notify_bin [|
        Config.notify_bin;
        title.title;
        "-i"; img;
        "-t"; "10000";
        Printf.sprintf "%s - %s %s"
          title.artist
          title.album
          title.year
      |]
;;
