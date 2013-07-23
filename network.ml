let get (url: string): string =
  let c = Curl.init () in
  Curl.set_url c url;
  Curl.set_followlocation c true;
  let buf = ref [] in
  Curl.set_writefunction c (fun s ->
    buf := s :: !buf;
    String.length s
  );
  Curl.perform c;
  String.concat "" (List.rev !buf)
;;
