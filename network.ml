let fetch (url: string) (f: string -> int): unit =
  let c = Curl.init () in
  Curl.set_url c url;
  Curl.set_followlocation c true;
  Curl.set_writefunction c f;
  Curl.perform c

let get (url: string): string =
  let buf = ref [] in
  fetch url (fun s ->
    buf := s :: !buf;
    String.length s
  );
  String.concat "" (List.rev !buf)
;;

let save (url: string): string =
  let file = Filename.temp_file "fip" ".jpg" in
  let oc = open_out file in
  fetch url (fun s ->
    output_string oc s;
    String.length s
  );
  close_out oc;
  file
;;
