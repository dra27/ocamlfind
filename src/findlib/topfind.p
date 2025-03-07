(* $Id$ -*- tuareg -*- *)

(* For Ocaml-3.03 and up, so you can do: #use "topfind" and get a
 * working findlib toploop.
 *)

#directory "@SITELIB@/findlib";;
  (* OCaml-4.00 requires to have #directory before we load anything *)
4x:
4x:#directory "+compiler-libs";;
4x:  (* For OCaml-4.00. This directory will be later removed from path *)

(* First test whether findlib_top is already loaded. If not, load it now.
 * The test works by executing the toplevel phrase "Topfind.reset" and
 * checking whether this causes an error.
 *)
let exec_test s =
  let l = Lexing.from_string s in
  let ph = !Toploop.parse_toplevel_phrase l in
  let fmt = Format.make_formatter (fun _ _ _ -> ()) (fun _ -> ()) in
  try
    Toploop.execute_phrase false fmt ph
  with
      _ -> false
in
let is_native =
  (* one of the few observable differences... *)
  Gc.((get()).stack_limit) = 0 in
let suffix =
  if is_native then "cmxs" else "cma" in
if not(exec_test "Topfind.reset;;") then (
  Topdirs.dir_load Format.err_formatter ("@SITELIB@/findlib/findlib." ^ suffix);
  Topdirs.dir_load Format.err_formatter ("@SITELIB@/findlib/findlib_top." ^ suffix);
);
;;
4x:
4x:#remove_directory "+compiler-libs";;

(* The following is always executed. It is harmless if findlib was already
 * initialized
 *)

let is_native =
  (* one of the few observable differences... *)
  Gc.((get()).stack_limit) = 0 in
let pred =
  if is_native then "native" else "byte" in
Topfind.add_predicates [ pred; "toploop" ];
Topfind.don't_load ["findlib"];
Topfind.announce();;
