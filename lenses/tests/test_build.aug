(*
Module: Test_Build
  Provides unit tests and examples for the <Build> lens.
*)

module Test_Build =

(* View: block_entry
    The block entry used for testing *)
let block_entry = Build.key_value "test" Sep.equal (store Rx.word)

(* View: block
    The block used for testing *)
let block = Build.block block_entry

(* Test: block
     Simple test for <block> *)
test block get " {test=1}" =
  { "test" = "1" }

(* Test: block
     Simple test for <block> with newlines *)
test block get " {\n test=1\n}" =
  { "test" = "1" }

(* Test: block
     Simple test for <block> two indented entries *)
test block get " {\n test=1 \n  test=2 \n}" =
  { "test" = "1" }
  { "test" = "2" }

(* Test: block
     Test <block> with a comment *)
test block get " { # This is a comment\n}" =
  { "#comment" = "This is a comment" }

(* Test: block
     Test <block> with comments and newlines *)
test block get " { # This is a comment\n# Another comment\n}" =
  { "#comment" = "This is a comment" }
  { "#comment" = "Another comment" }

(* Test: block
     Test defaults for blocks *)
test block put " { test=1 }" after
   set "/#comment" "a comment";
   rm "/test";
   set "/test" "2" =
  " { # a comment\ntest=2 }"

(* View: named_block
    The named block used for testing *)
let named_block = Build.named_block "foo" block_entry

(* Test: named_block
     Simple test for <named_block> *)
test named_block get "foo {test=1}\n" =
  { "foo" { "test" = "1" } }

(* View: logrotate_block
    A minimalistic logrotate block *)
let logrotate_block =
      let entry = [ key Rx.word ] 
   in let filename = [ label "file" . store /\/[^,#= \n\t{}]+/ ]
   in let filename_sep = del /[ \t\n]+/ " "
   in let filenames = Build.opt_list filename filename_sep
   in [ label "rule" . filenames . Build.block entry ]

(* Test: logrotate_block *)
test logrotate_block get "/var/log/wtmp\n/var/log/wtmp2\n{
   missingok
   monthly
}" =
  { "rule"
    { "file" = "/var/log/wtmp" }
    { "file" = "/var/log/wtmp2" }
    { "missingok" }
    { "monthly" }
  }

