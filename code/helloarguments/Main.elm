import Html exposing (text)
main : Html.Html msg
main =
  text (bottlesOf "juice" 99)

bottlesOf : String -> Int -> String
bottlesOf contents amount =
  toString amount ++ " bottles of " ++ contents
