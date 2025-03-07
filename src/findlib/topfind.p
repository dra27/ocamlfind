(* $Id$ -*- tuareg -*- *)

(* For Ocaml-3.03 and up, so you can do: #use "topfind" and get a
 * working findlib toploop.
 *)
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
let findlib_directory = "@SITELIB@/findlib" in
rx:let module Defs = struct
rx:  external standard_library_default : unit -> string = "%standard_library_default"
rx:  external stdlib_dirs : string -> string * string option = "caml_sys_get_stdlib_dirs"
rx:end in
rx:let stdlib, _ = Defs.stdlib_dirs (Defs.standard_library_default ()) in
rx:let findlib_directory = Filename.concat stdlib findlib_directory in
(* This must be executed before exec_test is called, as executing Topfind.reset
   when topfind.cmi is not in the search path creates a permanent error in
   OCaml 4.00+ and Topfind.add_predicates fails even after loading the .cma *)
let () = Topdirs.dir_directory findlib_directory in
let is_native =
  (* one of the few observable differences... *)
  Gc.((get()).stack_limit) = 0 in
let suffix =
  if is_native then "cmxs" else "cma" in
if not(exec_test "Topfind.reset;;") then (
  Topdirs.dir_load Format.err_formatter (findlib_directory ^ "/findlib." ^ suffix);
  Topdirs.dir_load Format.err_formatter (findlib_directory ^ "/findlib_top." ^ suffix);
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
