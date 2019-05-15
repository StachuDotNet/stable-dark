open Tc
open Types
open Prelude

type token = Types.fluidToken

type tokenInfo = Types.fluidTokenInfo

let tid (t : token) : id =
  match t with
  | TInteger (id, _)
  | TFloatWhole (id, _)
  | TFloatPoint id
  | TFloatFraction (id, _)
  | TTrue id
  | TFalse id
  | TNullToken id
  | TBlank id
  | TPartial (id, _)
  | TLetKeyword id
  | TLetAssignment id
  | TLetLHS (id, _)
  | TString (id, _)
  | TIfKeyword id
  | TIfThenKeyword id
  | TIfElseKeyword id
  | TBinOp (id, _)
  | TFieldOp id
  | TFieldName (id, _)
  | TVariable (id, _)
  | TFnName (id, _)
  | TLambdaVar (id, _)
  | TLambdaArrow id
  | TLambdaSymbol id
  | TLambdaSep id
  | TListOpen id
  | TListClose id
  | TListSep id
  | TThreadPipe (id, _)
  | TRecordOpen id
  | TRecordClose id
  | TRecordField (id, _, _)
  | TRecordSep (id, _) ->
      id
  | TSep | TNewline | TIndented _ | TIndent _ | TIndentToHere _ ->
      ID "no-id"


let isBlank t =
  match t with
  | TBlank _
  | TRecordField (_, _, "")
  | TFieldName (_, "")
  | TLetLHS (_, "")
  | TLambdaVar (_, "")
  | TPartial _ ->
      true
  | _ ->
      false


let isAutocompletable (t : token) : bool =
  match t with TBlank _ | TPartial _ -> true | _ -> false


let toText (t : token) : string =
  let shouldntBeEmpty name =
    if name = ""
    then (
      Js.log2 "shouldn't be empty" (show_fluidToken t) ;
      "   " )
    else name
  in
  let canBeEmpty name = if name = "" then "   " else name in
  match t with
  | TInteger (_, i) ->
      shouldntBeEmpty i
  | TFloatWhole (_, w) ->
      shouldntBeEmpty w
  | TFloatPoint _ ->
      "."
  | TFloatFraction (_, f) ->
      f
  | TString (_, str) ->
      "\"" ^ str ^ "\""
  | TTrue _ ->
      "true"
  | TFalse _ ->
      "false"
  | TNullToken _ ->
      "null"
  | TBlank _ ->
      "   "
  | TPartial (_, str) ->
      canBeEmpty str
  | TSep ->
      " "
  | TNewline ->
      "\n"
  | TLetKeyword _ ->
      "let "
  | TLetAssignment _ ->
      " = "
  | TLetLHS (_, name) ->
      canBeEmpty name
  | TIfKeyword _ ->
      "if "
  | TIfThenKeyword _ ->
      "then"
  | TIfElseKeyword _ ->
      "else"
  | TBinOp (_, op) ->
      shouldntBeEmpty op
  | TFieldOp _ ->
      "."
  | TFieldName (_, name) ->
      canBeEmpty name
  | TVariable (_, name) ->
      canBeEmpty name
  | TFnName (_, name) ->
      shouldntBeEmpty name
  | TLambdaVar (_, name) ->
      canBeEmpty name
  | TLambdaSymbol _ ->
      "\\"
  | TLambdaSep _ ->
      " "
  | TLambdaArrow _ ->
      " -> "
  | TIndent indent ->
      shouldntBeEmpty (Caml.String.make indent ' ')
  (* We dont want this to be transparent, so have these make their presence
   * known *)
  | TIndented _ ->
      "TIndented"
  | TIndentToHere _ ->
      "TIndentToHere"
  | TListOpen _ ->
      "["
  | TListClose _ ->
      "]"
  | TListSep _ ->
      ","
  | TRecordOpen _ ->
      "{"
  | TRecordClose _ ->
      "}"
  | TRecordField (_, _, name) ->
      canBeEmpty name
  | TRecordSep _ ->
      ":"
  | TThreadPipe _ ->
      "|>"


let toTestText (t : token) : string =
  match t with
  | TBlank _ ->
      "___"
  | TPartial (_, str) ->
      str
  | _ ->
      if isBlank t then "***" else toText t


let toTypeName (t : token) : string =
  match t with
  | TInteger _ ->
      "integer"
  | TFloatWhole _ ->
      "float-whole"
  | TFloatPoint _ ->
      "float-point"
  | TFloatFraction _ ->
      "float-fraction"
  | TString (_, _) ->
      "string"
  | TTrue _ ->
      "true"
  | TFalse _ ->
      "false"
  | TNullToken _ ->
      "null"
  | TBlank _ ->
      "blank"
  | TPartial _ ->
      "partial"
  | TLetKeyword _ ->
      "let-keyword"
  | TLetAssignment _ ->
      "let-assignment"
  | TLetLHS _ ->
      "let-lhs"
  | TSep ->
      "sep"
  | TIndented _ ->
      "indented"
  | TIndentToHere _ ->
      "indent-to-here"
  | TIndent _ ->
      "indent"
  | TNewline ->
      "newline"
  | TIfKeyword _ ->
      "if-keyword"
  | TIfThenKeyword _ ->
      "if-then-keyword"
  | TIfElseKeyword _ ->
      "if-else-keyword"
  | TBinOp _ ->
      "binop"
  | TFieldOp _ ->
      "field-op"
  | TFieldName _ ->
      "field-name"
  | TVariable _ ->
      "variable"
  | TFnName (_, _) ->
      "fn-name"
  | TLambdaVar (_, _) ->
      "lambda-var"
  | TLambdaSymbol _ ->
      "lambda-symbol"
  | TLambdaArrow _ ->
      "lambda-arrow"
  | TLambdaSep _ ->
      "lambda-sep"
  | TListOpen _ ->
      "list-open"
  | TListClose _ ->
      "list-close"
  | TListSep _ ->
      "list-sep"
  | TRecordOpen _ ->
      "record-open"
  | TRecordClose _ ->
      "record-close"
  | TRecordField _ ->
      "record-field"
  | TRecordSep _ ->
      "record-sep"
  | TThreadPipe _ ->
      "thread-pipe"


let toCategoryName (t : token) : string =
  match t with
  | TInteger _ | TString _ ->
      "literal"
  | TVariable _ | TNewline | TSep | TBlank _ | TPartial _ ->
      ""
  | TFloatWhole _ | TFloatPoint _ | TFloatFraction _ ->
      "float"
  | TTrue _ | TFalse _ ->
      "boolean"
  | TNullToken _ ->
      "null"
  | TFnName _ | TBinOp _ ->
      "function"
  | TLetKeyword _ | TLetAssignment _ | TLetLHS _ ->
      "let"
  | TIndented _ | TIndentToHere _ | TIndent _ ->
      "indent"
  | TIfKeyword _ | TIfThenKeyword _ | TIfElseKeyword _ ->
      "if"
  | TFieldOp _ | TFieldName _ ->
      "field"
  | TLambdaVar _ | TLambdaSymbol _ | TLambdaArrow _ | TLambdaSep _ ->
      "lambda"
  | TListOpen _ | TListClose _ | TListSep _ ->
      "list"
  | TThreadPipe _ ->
      "thread"
  | TRecordOpen _ | TRecordClose _ | TRecordField _ | TRecordSep _ ->
      "record"


let toCssClasses (t : token) : string =
  let keyword =
    match t with
    | TLetKeyword _ | TIfKeyword _ | TIfThenKeyword _ | TIfElseKeyword _ ->
        "fluid-keyword"
    | _ ->
        ""
  in
  let empty =
    match t with
    | TLetLHS (_, "")
    | TFieldName (_, "")
    | TLambdaVar (_, "")
    | TRecordField (_, _, "") ->
        "fluid-empty"
    | _ ->
        ""
  in
  String.trim (keyword ^ " " ^ empty)
  ^ " fluid-"
  ^ toCategoryName t
  ^ " fluid-"
  ^ toTypeName t


let show_tokenInfo (ti : tokenInfo) =
  Printf.sprintf
    "(%d, %d), '%s', %s (%s)"
    ti.startPos
    ti.endPos
    (* ti.length *)
    (toText ti.token)
    (tid ti.token |> deID)
    (toTypeName ti.token)