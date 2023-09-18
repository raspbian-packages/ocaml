(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(** The run-time library for lexers generated by [ocamllex]. *)

(** {1 Positions} *)

type position = {
  pos_fname : string;
  pos_lnum : int;
  pos_bol : int;
  pos_cnum : int;
}
(** A value of type [position] describes a point in a source file.
   [pos_fname] is the file name; [pos_lnum] is the line number;
   [pos_bol] is the offset of the beginning of the line (number
   of characters between the beginning of the lexbuf and the beginning
   of the line); [pos_cnum] is the offset of the position (number of
   characters between the beginning of the lexbuf and the position).
   The difference between [pos_cnum] and [pos_bol] is the character
   offset within the line (i.e. the column number, assuming each
   character is one column wide).

   See the documentation of type [lexbuf] for information about
   how the lexing engine will manage positions.
 *)

val dummy_pos : position
(** A value of type [position], guaranteed to be different from any
   valid position.
 *)


(** {1 Lexer buffers} *)


type lexbuf =
  { refill_buff : lexbuf -> unit;
    mutable lex_buffer : bytes;
    mutable lex_buffer_len : int;
    mutable lex_abs_pos : int;
    mutable lex_start_pos : int;
    mutable lex_curr_pos : int;
    mutable lex_last_pos : int;
    mutable lex_last_action : int;
    mutable lex_eof_reached : bool;
    mutable lex_mem : int array;
    mutable lex_start_p : position;
    mutable lex_curr_p : position;
  }
(** The type of lexer buffers. A lexer buffer is the argument passed
   to the scanning functions defined by the generated scanners.
   The lexer buffer holds the current state of the scanner, plus
   a function to refill the buffer from the input.

   Lexers can optionally maintain the [lex_curr_p] and [lex_start_p]
   position fields.  This "position tracking" mode is the default, and
   it corresponds to passing [~with_position:true] to functions that
   create lexer buffers. In this mode, the lexing engine and lexer
   actions are co-responsible for properly updating the position
   fields, as described in the next paragraph.  When the mode is
   explicitly disabled (with [~with_position:false]), the lexing
   engine will not touch the position fields and the lexer actions
   should be careful not to do it either; the [lex_curr_p] and
   [lex_start_p] field will then always hold the [dummy_pos] invalid
   position.  Not tracking positions avoids allocations and memory
   writes and can significantly improve the performance of the lexer
   in contexts where [lex_start_p] and [lex_curr_p] are not needed.

   Position tracking mode works as follows.  At each token, the lexing
   engine will copy [lex_curr_p] to [lex_start_p], then change the
   [pos_cnum] field of [lex_curr_p] by updating it with the number of
   characters read since the start of the [lexbuf].  The other fields
   are left unchanged by the lexing engine.  In order to keep them
   accurate, they must be initialised before the first use of the
   lexbuf, and updated by the relevant lexer actions (i.e. at each end
   of line -- see also [new_line]).
*)

val from_channel : ?with_positions:bool -> in_channel -> lexbuf
(** Create a lexer buffer on the given input channel.
   [Lexing.from_channel inchan] returns a lexer buffer which reads
   from the input channel [inchan], at the current reading position. *)

val from_string : ?with_positions:bool -> string -> lexbuf
(** Create a lexer buffer which reads from
   the given string. Reading starts from the first character in
   the string. An end-of-input condition is generated when the
   end of the string is reached. *)

val from_function : ?with_positions:bool -> (bytes -> int -> int) -> lexbuf
(** Create a lexer buffer with the given function as its reading method.
   When the scanner needs more characters, it will call the given
   function, giving it a byte sequence [s] and a byte
   count [n]. The function should put [n] bytes or fewer in [s],
   starting at index 0, and return the number of bytes
   provided. A return value of 0 means end of input. *)

val set_position : lexbuf -> position -> unit
(** Set the initial tracked input position for [lexbuf] to a custom value.
   Ignores [pos_fname]. See {!set_filename} for changing this field.
   @since 4.11 *)

val set_filename: lexbuf -> string -> unit
(** Set filename in the initial tracked position to [file] in
   [lexbuf].
   @since 4.11 *)

val with_positions : lexbuf -> bool
(** Tell whether the lexer buffer keeps track of position fields
    [lex_curr_p] / [lex_start_p], as determined by the corresponding
    optional argument for functions that create lexer buffers
    (whose default value is [true]).

    When [with_positions] is [false], lexer actions should not
    modify position fields.  Doing it nevertheless could
    re-enable the [with_position] mode and degrade performances.
*)


(** {1 Functions for lexer semantic actions} *)


(** The following functions can be called from the semantic actions
   of lexer definitions (the ML code enclosed in braces that
   computes the value returned by lexing functions). They give
   access to the character string matched by the regular expression
   associated with the semantic action. These functions must be
   applied to the argument [lexbuf], which, in the code generated by
   [ocamllex], is bound to the lexer buffer passed to the parsing
   function. *)

val lexeme : lexbuf -> string
(** [Lexing.lexeme lexbuf] returns the string matched by
           the regular expression. *)

val lexeme_char : lexbuf -> int -> char
(** [Lexing.lexeme_char lexbuf i] returns character number [i] in
   the matched string. *)

val lexeme_start : lexbuf -> int
(** [Lexing.lexeme_start lexbuf] returns the offset in the
   input stream of the first character of the matched string.
   The first character of the stream has offset 0. *)

val lexeme_end : lexbuf -> int
(** [Lexing.lexeme_end lexbuf] returns the offset in the input stream
   of the character following the last character of the matched
   string. The first character of the stream has offset 0. *)

val lexeme_start_p : lexbuf -> position
(** Like [lexeme_start], but return a complete [position] instead
    of an offset.  When position tracking is disabled, the function
    returns [dummy_pos]. *)

val lexeme_end_p : lexbuf -> position
(** Like [lexeme_end], but return a complete [position] instead
    of an offset.  When position tracking is disabled, the function
    returns [dummy_pos]. *)

val new_line : lexbuf -> unit
(** Update the [lex_curr_p] field of the lexbuf to reflect the start
    of a new line.  You can call this function in the semantic action
    of the rule that matches the end-of-line character.  The function
    does nothing when position tracking is disabled.
    @since 3.11.0
*)

(** {1 Miscellaneous functions} *)

val flush_input : lexbuf -> unit
(** Discard the contents of the buffer and reset the current
    position to 0.  The next use of the lexbuf will trigger a
    refill. *)

(**/**)

(** The following definitions are used by the generated scanners only.
   They are not intended to be used directly by user programs. *)

val sub_lexeme : lexbuf -> int -> int -> string
val sub_lexeme_opt : lexbuf -> int -> int -> string option
val sub_lexeme_char : lexbuf -> int -> char
val sub_lexeme_char_opt : lexbuf -> int -> char option

type lex_tables =
  { lex_base : string;
    lex_backtrk : string;
    lex_default : string;
    lex_trans : string;
    lex_check : string;
    lex_base_code : string;
    lex_backtrk_code : string;
    lex_default_code : string;
    lex_trans_code : string;
    lex_check_code : string;
    lex_code: string;}

val engine : lex_tables -> int -> lexbuf -> int
val new_engine : lex_tables -> int -> lexbuf -> int
