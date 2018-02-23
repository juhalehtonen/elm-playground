module Main exposing (main)
import Html exposing (text)
main : Html.Html msg
main =
  text (sayHello "Evermade")


sayHello : String -> String
sayHello name =
  "Hello, " ++ name
