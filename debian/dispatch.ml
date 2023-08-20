(*
  Description: called from debian/rules, generates debhelper's .install files
  Copyright © 2019-2021 Stéphane Glondu <glondu@debian.org>
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

let chop_prefix ~prefix str =
  let p = String.length prefix and n = String.length str in
  if n >= p && String.sub str 0 p = prefix then
    Some (String.sub str p (n - p))
  else
    None

let get_base str =
  let n = String.length str in
  let last_slash = String.rindex_from str (n - 1) '/' in
  let first_dot = try String.index_from str last_slash '.' with Not_found -> n in
  let try_prefix prefix x = Option.value ~default:x (chop_prefix ~prefix x) in
  String.sub str (last_slash + 1) (first_dot - last_slash - 1)
  |> try_prefix "dll"
  |> try_prefix "lib"
  |> try_prefix "stdlib__"

module SMap = Map.Make (String)
module SSet = Set.Make (String)

let dev_stdlib = ref []
let run_stdlib = ref []
let dev_compiler_libs = ref []

let ocaml_base = ref [ "debian/ld.conf usr/lib/ocaml" ]
let ocaml =
  ref [
      "debian/native-archs usr/lib/ocaml";
    ]
let ocaml_interp =
  ref [
      "debian/ocaml.desktop usr/share/applications";
      "debian/ocaml.xpm usr/share/pixmaps";
    ]
let ocaml_man = ref []

let pkgs = [
    run_stdlib, "libstdlib-ocaml";
    dev_stdlib, "libstdlib-ocaml-dev";
    dev_compiler_libs, "libcompiler-libs-ocaml-dev";
    ocaml_base, "ocaml-base";
    ocaml, "ocaml";
    ocaml_interp, "ocaml-interp";
    ocaml_man, "ocaml-man";
  ]

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
      "usr/bin/ocamllex", ocaml;
      "usr/bin/ocamlopt", ocaml;
      "usr/bin/ocamloptp", ocaml;
      "usr/bin/ocamlcp", ocaml;
      "usr/bin/ocamlc", ocaml;
      "usr/bin/ocamldep", ocaml;
      "usr/bin/ocamlobjinfo", ocaml;
      "usr/bin/ocamlmklib", ocaml;
      "usr/bin/ocamlprof", ocaml;
      "usr/bin/ocamlmktop", ocaml;
      "usr/lib/ocaml/camlheader", ocaml;
      "usr/lib/ocaml/camlheaderd", ocaml;
      "usr/lib/ocaml/camlheaderi", ocaml;
      "usr/lib/ocaml/eventlog_metadata", ocaml;
      "usr/lib/ocaml/Makefile.config", ocaml;
      "usr/lib/ocaml/extract_crc", ocaml;
      "usr/lib/ocaml/camlheader_ur", ocaml;
      "usr/lib/ocaml/expunge", ocaml;
      "usr/lib/ocaml/VERSION", ocaml_base;
      "usr/lib/ocaml/target_camlheaderd", ocaml;
      "usr/lib/ocaml/objinfo_helper", ocaml;
      "usr/lib/ocaml/target_camlheaderi", ocaml;
      "usr/bin/ocamlmklib.opt", ocaml;
      "usr/bin/ocamllex.byte", ocaml;
      "usr/bin/ocamldebug", ocaml;
      "usr/bin/ocamlobjinfo.byte", ocaml;
      "usr/bin/ocamlprof.byte", ocaml;
      "usr/bin/ocamloptp.opt", ocaml;
      "usr/bin/ocamlmklib.byte", ocaml;
      "usr/bin/ocamlrund", ocaml_base;
      "usr/bin/ocamlcp.byte", ocaml;
      "usr/bin/ocamldep.opt", ocaml;
      "usr/bin/ocamldoc.opt", ocaml;
      "usr/bin/ocamlobjinfo.opt", ocaml;
      "usr/bin/ocamlyacc", ocaml;
      "usr/bin/ocaml-instr-graph", ocaml;
      "usr/bin/ocamlcmt", ocaml;
      "usr/bin/ocamlmktop.byte", ocaml;
      "usr/bin/ocamldoc", ocaml;
      "usr/bin/ocaml", ocaml_interp;
      "usr/bin/ocamlcp.opt", ocaml;
      "usr/bin/ocaml-instr-report", ocaml;
      "usr/bin/ocamldep.byte", ocaml;
      "usr/bin/ocamloptp.byte", ocaml;
      "usr/bin/ocamlprof.opt", ocaml;
      "usr/bin/ocamlc.byte", ocaml;
      "usr/bin/ocamlruni", ocaml_base;
      "usr/bin/ocamllex.opt", ocaml;
      "usr/bin/ocamlopt.opt", ocaml;
      "usr/bin/ocamlmktop.opt", ocaml;
      "usr/bin/ocamlopt.byte", ocaml;
      "usr/bin/ocamlrun", ocaml_base;
      "usr/bin/ocamlc.opt", ocaml;
      "usr/share/man/man1/ocaml.1", ocaml_interp;
      "usr/share/man/man1/ocamllex.1", ocaml;
      "usr/share/man/man1/ocamlyacc.1", ocaml;
      "usr/share/man/man1/ocamlrun.1", ocaml_base;
      "usr/share/man/man1/ocamldoc.1", ocaml;
      "usr/share/man/man1/ocamlcp.1", ocaml;
      "usr/share/man/man1/ocamloptp.1", ocaml;
      "usr/share/man/man1/ocamlc.1", ocaml;
      "usr/share/man/man1/ocamldep.1", ocaml;
      "usr/share/man/man1/ocamlmktop.1", ocaml;
      "usr/share/man/man1/ocamlopt.1", ocaml;
      "usr/share/man/man1/ocamlprof.1", ocaml;
      "usr/share/man/man1/ocamldebug.1", ocaml;
    ]

let base_set = ref SSet.empty

let () =
  List.iter (fun x ->
      match chop_prefix ~prefix:"usr/lib/ocaml/stdlib__" x with
      | None -> ()
      | Some x ->
         let i = String.index x '.' in
         base_set := SSet.add (String.sub x 0 i) !base_set
    ) installed_files

let () =
  List.iter (fun x -> base_set := SSet.add x !base_set)
    [
      "camlinternalOO"; "camlinternalMod"; "camlinternalLazy";
      "camlinternalFormatBasics"; "camlinternalFormat";
      "camlinternalAtomic";
      "topdirs";
      "unix"; "unixLabels";
      "str"; "camlstr";
      "threads"; "vmthreads"; "threadsnat";
      "profiling";
      "camlrun"; "camlrund"; "camlruni"; "camlrun_pic"; "camlrun_shared";
      "asmrun"; "asmrund"; "asmruni"; "asmrunp"; "asmrun_shared"; "asmrun_pic";
      "raw_spacetime_lib";
    ]

let exts_dev = [ ".ml"; ".mli"; ".cmi"; ".cmt"; ".cmti"; ".cmx"; ".cmxa"; ".a"; ".cmo"; ".o" ]
let exts_run = [ ".cma"; ".cmxs"; ".so" ]

let push xs x = xs := x :: !xs; None

let process_static x =
  match SMap.find_opt x !static_map with
  | Some pkg -> push pkg x
  | None -> Some x

let find_base base =
  match SSet.mem base !base_set with
  | true -> true
  | false -> SSet.mem (String.capitalize_ascii base) !base_set

let process_file x =
  let base = get_base x in
  match find_base base with
  | true ->
     if List.exists (fun suffix -> String.ends_with ~suffix x) exts_dev then (
       push dev_stdlib x
     ) else if List.exists (fun suffix -> String.ends_with ~suffix x) exts_run then (
       push run_stdlib x
     ) else Some x
  | false -> Some x

let remaining =
  installed_files
  |> move_all_to ocaml (String.starts_with ~prefix:"usr/lib/ocaml/caml/")
  |> move_all_to dev_stdlib (String.starts_with ~prefix:"usr/lib/ocaml/threads/")
  |> move_all_to dev_stdlib (String.starts_with ~prefix:"usr/lib/ocaml/std_exit.")
  |> move_all_to dev_stdlib (String.starts_with ~prefix:"usr/lib/ocaml/stdlib.")
  |> move_all_to dev_stdlib (String.starts_with ~prefix:"usr/lib/ocaml/dynlink")
  |> move_all_to dev_compiler_libs (String.starts_with ~prefix:"usr/lib/ocaml/topdirs.")
  |> move_all_to dev_compiler_libs (String.starts_with ~prefix:"usr/lib/ocaml/compiler-libs/")
  |> move_all_to dev_compiler_libs (String.starts_with ~prefix:"usr/lib/ocaml/ocamldoc/")
  |> move_all_to ocaml_man (String.ends_with ~suffix:".3o")
  |> rev_filter_map process_static
  |> rev_filter_map process_file

let () = assert (remaining = [])

let () =
  List.iter (fun (pkg, name) ->
      let oc = Printf.ksprintf open_out "debian/%s.install" name in
      List.iter (Printf.fprintf oc "%s\n") !pkg;
      close_out oc
    ) pkgs
