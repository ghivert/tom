import tom
import gleam/map
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn parse_empty_test() {
  ""
  |> tom.parse
  |> should.equal(Ok(map.from_list([])))
}

pub fn parse_spaces_test() {
  " "
  |> tom.parse
  |> should.equal(Ok(map.from_list([])))
}

pub fn parse_newline_test() {
  "\n"
  |> tom.parse
  |> should.equal(Ok(map.from_list([])))
}

pub fn parse_crlf_test() {
  "\r\n"
  |> tom.parse
  |> should.equal(Ok(map.from_list([])))
}

pub fn parse_quoted_key_test() {
  let expected = map.from_list([#(" ", tom.Bool(True))])
  "\" \" = true\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_single_key_test() {
  let expected = map.from_list([#("", tom.Bool(True))])
  "'' = true\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_true_test() {
  let expected = map.from_list([#("cool", tom.Bool(True))])
  "cool = true\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_false_test() {
  let expected = map.from_list([#("cool", tom.Bool(False))])
  "cool = false\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_unicode_key_test() {
  let expected = map.from_list([#("பெண்", tom.Bool(False))])
  "பெண் = false\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_int_test() {
  let expected = map.from_list([#("it", tom.Int(1))])
  "it = 1\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_int_underscored_test() {
  let expected = map.from_list([#("it", tom.Int(1_000_009))])
  "it = 1_000_0__0_9\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_int_positive_test() {
  let expected = map.from_list([#("it", tom.Int(234))])
  "it = +234\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_int_negative_test() {
  let expected = map.from_list([#("it", tom.Int(-234))])
  "it = -234\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_string_test() {
  let expected = map.from_list([#("hello", tom.String("Joe"))])
  "hello = \"Joe\"\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_string_escaped_quote_test() {
  let expected = map.from_list([#("hello", tom.String("\""))])
  "hello = \"\\\"\"\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_string_tab_test() {
  let expected = map.from_list([#("hello", tom.String("\t"))])
  "hello = \"\\t\"\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_string_newline_test() {
  let expected = map.from_list([#("hello", tom.String("\n"))])
  "hello = \"\\n\"\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_string_linefeed_test() {
  let expected = map.from_list([#("hello", tom.String("\r"))])
  "hello = \"\\r\"\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_escaped_slash_test() {
  let expected = map.from_list([#("hello", tom.String("\\"))])
  "hello = \"\\\\\"\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_float_test() {
  let expected = map.from_list([#("it", tom.Float(1.0))])
  "it = 1.0\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_bigger_float_test() {
  let expected = map.from_list([#("it", tom.Float(123_456_789.9876))])
  "it = 123456789.9876\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_multi_segment_key_test() {
  let expected =
    map.from_list([
      #(
        "one",
        tom.Table(map.from_list([
          #("two", tom.Table(map.from_list([#("three", tom.Bool(True))]))),
        ])),
      ),
    ])
  "one.two.three = true\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_multi_segment_key_with_spaeces_test() {
  let expected =
    map.from_list([
      #(
        "one",
        tom.Table(map.from_list([
          #("two", tom.Table(map.from_list([#("three", tom.Bool(True))]))),
        ])),
      ),
    ])
  "one  . two   .   three = true\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_multi_segment_key_quotes_test() {
  let expected =
    map.from_list([
      #(
        "1",
        tom.Table(map.from_list([
          #("two", tom.Table(map.from_list([#("3", tom.Bool(True))]))),
        ])),
      ),
    ])
  "\"1\".two.\"3\" = true\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_multiple_keys_test() {
  let expected = map.from_list([#("a", tom.Int(1)), #("b", tom.Int(2))])
  "a = 1\nb = 2\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_duplicate_key_test() {
  "a = 1\na = 2\n"
  |> tom.parse
  |> should.equal(Error(tom.KeyAlreadyInUse(["a"])))
}

pub fn parse_conflicting_keys_test() {
  "a = 1\na.b = 2\n"
  |> tom.parse
  |> should.equal(Error(tom.KeyAlreadyInUse(["a"])))
}

pub fn parse_empty_array_test() {
  let expected = map.from_list([#("a", tom.Array([]))])
  "a = []\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_array_test() {
  let expected = map.from_list([#("a", tom.Array([tom.Int(1), tom.Int(2)]))])
  "a = [1, 2]\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_multi_line_array_test() {
  let expected = map.from_list([#("a", tom.Array([tom.Int(1), tom.Int(2)]))])
  "a = [\n  1 \n ,\n  2,\n]\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_table_test() {
  let expected = map.from_list([#("a", tom.Table(map.from_list([])))])
  "[a]\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_table_with_values_test() {
  let expected =
    map.from_list([
      #(
        "a",
        tom.Table(map.from_list([
          #("a", tom.Int(1)),
          #("b", tom.Table(map.from_list([#("c", tom.Int(2))]))),
        ])),
      ),
    ])
  "[a]
a = 1
b.c = 2
"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_table_with_values_before_test() {
  let expected =
    map.from_list([
      #("name", tom.String("Joe")),
      #("size", tom.Int(123)),
      #(
        "a",
        tom.Table(map.from_list([
          #("a", tom.Int(1)),
          #("b", tom.Table(map.from_list([#("c", tom.Int(2))]))),
        ])),
      ),
    ])
  "name = \"Joe\"
size = 123

[a]
a = 1
b.c = 2
"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_multiple_tables_test() {
  let expected =
    map.from_list([
      #("name", tom.String("Joe")),
      #("size", tom.Int(123)),
      #(
        "a",
        tom.Table(map.from_list([
          #("a", tom.Int(1)),
          #("b", tom.Table(map.from_list([#("c", tom.Int(2))]))),
        ])),
      ),
      #("b", tom.Table(map.from_list([#("a", tom.Int(1))]))),
    ])
  "name = \"Joe\"
size = 123

[a]
a = 1
b.c = 2

[b]
a = 1
"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_inline_table_empty_test() {
  let expected = map.from_list([#("a", tom.InlineTable(map.from_list([])))])
  "a = {}\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_inline_table_test() {
  let expected =
    map.from_list([
      #(
        "a",
        tom.InlineTable(map.from_list([
          #("a", tom.Int(1)),
          #("b", tom.Table(map.from_list([#("c", tom.Int(2))]))),
        ])),
      ),
    ])
  "a = {
  a = 1,
  b.c = 2
}
"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_inline_trailing_comma_table_test() {
  let expected =
    map.from_list([
      #(
        "a",
        tom.InlineTable(map.from_list([
          #("a", tom.Int(1)),
          #("b", tom.Table(map.from_list([#("c", tom.Int(2))]))),
        ])),
      ),
    ])
  "a = {
  a = 1,
  b.c = 2,
}
"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_invalid_newline_in_string_test() {
  "a = \"\n\""
  |> tom.parse
  |> should.equal(Error(tom.Unexpected("\n", "\"")))
}

pub fn parse_invalid_newline_windows_in_string_test() {
  "a = \"\r\n\""
  |> tom.parse
  |> should.equal(Error(tom.Unexpected("\r\n", "\"")))
}

pub fn parse_array_of_tables_empty_test() {
  let expected =
    map.from_list([
      #(
        "a",
        tom.ArrayOfTables([
          map.from_list([]),
          map.from_list([]),
          map.from_list([]),
        ]),
      ),
    ])
  "[[a]]
[[a]]
[[a]]
"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_array_of_tables_nonempty_test() {
  let expected =
    map.from_list([
      #(
        "a",
        tom.ArrayOfTables([
          map.from_list([#("a", tom.Int(1))]),
          map.from_list([#("a", tom.Int(2))]),
          map.from_list([#("a", tom.Int(3))]),
        ]),
      ),
    ])
  "[[a]]
a = 1
  
[[a]]
a = 2
  
[[a]]
a = 3
"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_array_of_tables_with_subtable_test() {
  let expected =
    map.from_list([
      #(
        "fruits",
        tom.ArrayOfTables([
          map.from_list([]),
          map.from_list([
            #("name", tom.String("apple")),
            #(
              "physical",
              tom.Table(map.from_list([
                #("color", tom.String("red")),
                #("shape", tom.String("round")),
              ])),
            ),
          ]),
        ]),
      ),
    ])
  "[[fruits]]

[[fruits]]
name = \"apple\"

[fruits.physical]  # subtable
color = \"red\"
shape = \"round\"
"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_single_quote_string_test() {
  let expected = map.from_list([#("a", tom.String("\\n"))])
  "a = '\\n'\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_multi_line_string_test() {
  let expected = map.from_list([#("a", tom.String("hello\nworld"))])
  "a = \"\"\"
hello
world\"\"\"
"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_multi_line_single_quote_string_test() {
  let expected = map.from_list([#("a", tom.String("hello\\n\nworld"))])
  "a = '''
hello\\n
world'''
"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_multi_line_single_quote_string_too_many_quotes_test() {
  "a = '''
''''
'''
"
  |> tom.parse
  |> should.equal(Error(tom.Unexpected("''''", "'''")))
}

pub fn parse_multi_line_string_escape_newline_test() {
  let expected =
    map.from_list([
      #("a", tom.String("The quick brown fox jumps over the lazy dog.")),
    ])
  "a = \"\"\"
The quick brown \\


  fox jumps over \\
    the lazy dog.\"\"\"
"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_multi_line_string_escape_newline_windows_test() {
  let expected =
    map.from_list([
      #("a", tom.String("The quick brown fox jumps over the lazy dog.")),
    ])
  "a = \"\"\"
The quick brown \\\r\n


  fox jumps over \\\r\n
    the lazy dog.\"\"\"
"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_nan_test() {
  let expected = map.from_list([#("a", tom.Nan(tom.Positive))])
  "a = nan\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_positive_nan_test() {
  let expected = map.from_list([#("a", tom.Nan(tom.Positive))])
  "a = +nan\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_negative_nan_test() {
  let expected = map.from_list([#("a", tom.Nan(tom.Negative))])
  "a = -nan\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_infinity_test() {
  let expected = map.from_list([#("a", tom.Infinity(tom.Positive))])
  "a = inf\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_positive_infinity_test() {
  let expected = map.from_list([#("a", tom.Infinity(tom.Positive))])
  "a = +inf\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_negative_infinity_test() {
  let expected = map.from_list([#("a", tom.Infinity(tom.Negative))])
  "a = -inf\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_write_to_key_that_does_not_exist_test() {
  let expected =
    map.from_list([
      #("apple", tom.Table(map.from_list([#("smooth", tom.Bool(True))]))),
    ])
  "apple.smooth = true\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_binary_test() {
  let expected = map.from_list([#("a", tom.Int(0b101010))])
  "a = 0b101010\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_binary_positive_test() {
  let expected = map.from_list([#("a", tom.Int(0b101010))])
  "a = +0b101010\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_binary_negative_test() {
  let expected = map.from_list([#("a", tom.Int(0b101010 * -1))])
  "a = -0b101010\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_binary_underscores_test() {
  let expected = map.from_list([#("a", tom.Int(0b101010))])
  "a = 0b1__010___1_0\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_octal_test() {
  let expected = map.from_list([#("a", tom.Int(0o1234567))])
  "a = 0o1234567\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_octal_positive_test() {
  let expected = map.from_list([#("a", tom.Int(0o1234567))])
  "a = +0o1234567\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_octal_negative_test() {
  let expected = map.from_list([#("a", tom.Int(0o1234567 * -1))])
  "a = -0o1234567\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}

pub fn parse_octal_underscores_test() {
  let expected = map.from_list([#("a", tom.Int(0o1234567))])
  "a = 0o1_23_45__6_7\n"
  |> tom.parse
  |> should.equal(Ok(expected))
}
