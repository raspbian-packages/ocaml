(*
  Description: called from debian/rules, generates debhelper's .install files
  Copyright © 2019 Stéphane Glondu <glondu@debian.org>
*)

let rev_filter_map f xs =
  let rec loop accu = function
    | [] -> accu
    | x :: xs ->
       match f x with
       | None -> loop accu xs
       | Some y -> loop (y :: accu) xs
  in loop [] xs

let rev_read_lines fn =
  let ic = open_in fn and res = ref [] in
  try
    while true do res := input_line ic :: !res done;
    assert false
  with End_of_file -> !res

let startswith prefix str =
  let p = String.length prefix and n = String.length str in
  n >= p && String.sub str 0 p = prefix

let endswith suffix str =
  let p = String.length suffix and n = String.length str in
  n >= p && String.sub str (n-p) p = suffix

let chop_prefix prefix str =
  let p = String.length prefix and n = String.length str in
  if n >= p && String.sub str 0 p = prefix then
    String.sub str p (n-p)
  else
    invalid_arg "chop_prefix"

let get_base str =
  let n = String.length str in
  let last_slash = String.rindex_from str (n - 1) '/' in
  let first_dot = try String.index_from str last_slash '.' with Not_found -> n in
  let try_prefix prefix x = if startswith prefix x then chop_prefix prefix x else x in
  String.sub str (last_slash + 1) (first_dot - last_slash - 1)
  |> try_prefix "dll"
  |> try_prefix "lib"
  |> try_prefix "stdlib__"

module SMap = Map.Make (String)

let ocaml_base_nox = ref [ "debian/ld.conf usr/lib/ocaml" ]
let ocaml_base = ref []
let ocaml_nox =
  ref [
      "debian/ocamlfind/ocaml-native-compilers.conf usr/share/ocaml-findlib/";
      "debian/native-archs usr/lib/ocaml";
    ]
let ocaml = ref []
let ocaml_compiler_libs = ref []
let ocaml_interp =
  ref [
      "debian/ocaml.desktop usr/share/applications";
      "debian/ocaml.xpm usr/share/pixmaps";
    ]
let ocaml_man = ref []

let pkgs = [
    ocaml_base_nox, "ocaml-base-nox";
    ocaml_base, "ocaml-base";
    ocaml_nox, "ocaml-nox";
    ocaml, "ocaml";
    ocaml_compiler_libs, "ocaml-compiler-libs";
    ocaml_interp, "ocaml-interp";
    ocaml_man, "ocaml-man";
  ]

let set_nox = ocaml_base_nox, ocaml_nox
let set_x = ocaml_base, ocaml

let installed_files = rev_read_lines "debian/installed-files"

let move_all_to pkg pred xs =
  let rec loop accu = function
    | [] -> accu
    | x :: xs ->
       if pred x then (
         pkg := x :: !pkg;
         loop accu xs
       ) else (
         loop (x :: accu) xs
       )
  in loop [] xs

let static_map = ref SMap.empty

let () =
  List.iter (fun (file, pkg) -> static_map := SMap.add file pkg !static_map)
    [
      "usr/bin/ocamllex", ocaml_nox;
      "usr/bin/ocamlopt", ocaml_nox;
      "usr/bin/ocamloptp", ocaml_nox;
      "usr/bin/ocamlcp", ocaml_nox;
      "usr/bin/ocamlc", ocaml_nox;
      "usr/bin/ocamldep", ocaml_nox;
      "usr/bin/ocamlobjinfo", ocaml_nox;
      "usr/bin/ocamlmklib", ocaml_nox;
      "usr/bin/ocamlprof", ocaml_nox;
      "usr/bin/ocamlmktop", ocaml_nox;
      "usr/lib/ocaml/camlheader", ocaml_nox;
      "usr/lib/ocaml/Makefile.config", ocaml_nox;
      "usr/lib/ocaml/extract_crc", ocaml_nox;
      "usr/lib/ocaml/camlheader_ur", ocaml_nox;
      "usr/lib/ocaml/expunge", ocaml_nox;
      "usr/lib/ocaml/VERSION", ocaml_base_nox;
      "usr/lib/ocaml/target_camlheaderd", ocaml_nox;
      "usr/lib/ocaml/objinfo_helper", ocaml_nox;
      "usr/lib/ocaml/target_camlheaderi", ocaml_nox;
      "usr/bin/ocamlmklib.opt", ocaml_nox;
      "usr/bin/ocamllex.byte", ocaml_nox;
      "usr/bin/ocamldebug", ocaml_nox;
      "usr/bin/ocamlobjinfo.byte", ocaml_nox;
      "usr/bin/ocamlprof.byte", ocaml_nox;
      "usr/bin/ocamloptp.opt", ocaml_nox;
      "usr/bin/ocamlmklib.byte", ocaml_nox;
      "usr/bin/ocamlrund", ocaml_base_nox;
      "usr/bin/ocamlcp.byte", ocaml_nox;
      "usr/bin/ocamldep.opt", ocaml_nox;
      "usr/bin/ocamldoc.opt", ocaml_nox;
      "usr/bin/ocamlobjinfo.opt", ocaml_nox;
      "usr/bin/ocamlyacc", ocaml_nox;
      "usr/bin/ocaml-instr-graph", ocaml_nox;
      "usr/bin/ocamlcmt", ocaml_nox;
      "usr/bin/ocamlmktop.byte", ocaml_nox;
      "usr/bin/ocamldoc", ocaml_nox;
      "usr/bin/ocaml", ocaml_interp;
      "usr/bin/ocamlcp.opt", ocaml_nox;
      "usr/bin/ocaml-instr-report", ocaml_nox;
      "usr/bin/ocamldep.byte", ocaml_nox;
      "usr/bin/ocamloptp.byte", ocaml_nox;
      "usr/bin/ocamlprof.opt", ocaml_nox;
      "usr/bin/ocamlc.byte", ocaml_nox;
      "usr/bin/ocamlruni", ocaml_base_nox;
      "usr/bin/ocamllex.opt", ocaml_nox;
      "usr/bin/ocamlopt.opt", ocaml_nox;
      "usr/bin/ocamlmktop.opt", ocaml_nox;
      "usr/bin/ocamlopt.byte", ocaml_nox;
      "usr/bin/ocamlrun", ocaml_base_nox;
      "usr/bin/ocamlc.opt", ocaml_nox;
      "usr/share/man/man1/ocaml.1", ocaml_interp;
      "usr/share/man/man1/ocamllex.1", ocaml_nox;
      "usr/share/man/man1/ocamlyacc.1", ocaml_nox;
      "usr/share/man/man1/ocamlrun.1", ocaml_base_nox;
      "usr/share/man/man1/ocamldoc.1", ocaml_nox;
      "usr/share/man/man1/ocamlcp.1", ocaml_nox;
      "usr/share/man/man1/ocamloptp.1", ocaml_nox;
      "usr/share/man/man1/ocamlc.1", ocaml_nox;
      "usr/share/man/man1/ocamldep.1", ocaml_nox;
      "usr/share/man/man1/ocamlmktop.1", ocaml_nox;
      "usr/share/man/man1/ocamlopt.1", ocaml_nox;
      "usr/share/man/man1/ocamlprof.1", ocaml_nox;
      "usr/share/man/man1/ocamldebug.1", ocaml_nox;
    ]

let base_map = ref SMap.empty

let () =
  List.iter (fun x ->
      try
        let x = chop_prefix "usr/lib/ocaml/stdlib__" x in
        let i = String.index x '.' in
        base_map := SMap.add (String.sub x 0 i) set_nox !base_map
      with _ -> ()
    ) installed_files

let () =
  List.iter (fun x -> base_map := SMap.add x set_nox !base_map)
    [
      "camlinternalOO"; "camlinternalMod"; "camlinternalLazy";
      "camlinternalFormatBasics"; "camlinternalFormat";
      "topdirs";
      "unix"; "unixLabels";
      "str"; "camlstr";
      "threads"; "vmthreads"; "threadsnat";
      "profiling";
      "camlrun"; "camlrund"; "camlruni"; "camlrun_pic"; "camlrun_shared";
      "asmrun"; "asmrund"; "asmruni"; "asmrunp"; "asmrun_shared"; "asmrun_pic";
      "raw_spacetime_lib";
    ]

let () =
  List.iter (fun x -> base_map := SMap.add x set_x !base_map)
    [ "graphics"; "graphicsX11" ]


let exts_dev = [ ".ml"; ".mli"; ".cmi"; ".cmt"; ".cmti"; ".cmx"; ".cmxa"; ".a"; ".cmo"; ".o" ]
let exts_run = [ ".cma"; ".cmxs"; ".so" ]

let push xs x = xs := x :: !xs; None

let process_static x =
  match SMap.find_opt x !static_map with
  | Some pkg -> push pkg x
  | None -> Some x

let process_file x =
  let base = get_base x in
  match SMap.find_opt base !base_map with
  | Some set ->
     if List.exists (fun y -> endswith y x) exts_dev then (
       push (snd set) x
     ) else if List.exists (fun y -> endswith y x) exts_run then (
       push (fst set) x
     ) else Some x
  | None -> Some x

let remaining =
  installed_files
  |> move_all_to ocaml_nox (startswith "usr/lib/ocaml/caml/")
  |> move_all_to ocaml_nox (startswith "usr/lib/ocaml/ocamldoc/")
  |> move_all_to ocaml_nox (startswith "usr/lib/ocaml/vmthreads/")
  |> move_all_to ocaml_nox (startswith "usr/lib/ocaml/threads/")
  |> move_all_to ocaml_nox (startswith "usr/lib/ocaml/std_exit.")
  |> move_all_to ocaml_nox (startswith "usr/lib/ocaml/stdlib.")
  |> move_all_to ocaml_nox (startswith "usr/lib/ocaml/dynlink")
  |> move_all_to ocaml_compiler_libs (startswith "usr/lib/ocaml/compiler-libs/")
  |> move_all_to ocaml_man (endswith ".3o")
  |> rev_filter_map process_static
  |> rev_filter_map process_file

let () = assert (remaining = [])

let () =
  List.iter (fun (pkg, name) ->
      let oc = Printf.ksprintf open_out "debian/%s.install" name in
      List.iter (Printf.fprintf oc "%s\n") !pkg;
      close_out oc
    ) pkgs
