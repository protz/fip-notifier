let get_match s =
  Str.matched_group 1 s

let matches r s =
  let r = Str.regexp r in
  try
    ignore (Str.search_forward r s 0);
    true
  with Not_found ->
    false

let matches_div c s =
  let r = Printf.sprintf "<div class=\"%s\">\\([^<]+\\)" c in
  matches r s

let split needle haystack =
  let r = Str.regexp needle in
  Str.split r haystack
