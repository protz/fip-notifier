(* [notify title img] displays a notification using libnotify for [title], using
 * the path specified in [img] for the image. *)
let notify (title: Title.t) (img: string): unit =
  let open Title in
  if Unix.fork () = 0 then
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
