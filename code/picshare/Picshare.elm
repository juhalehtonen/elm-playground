{-
Every Elm file is a module. Modules let you organize code into logical units.
Every module contains one or more constants and functions that it can expose
to other modules. The name of `main` constant is important but not the modules
name.
-}
module Picshare exposing (main)
-- We expose the Html TYPE constructor to represent HTML in addition to div and text functions
-- Html essentially represents the virtual DOM.
import Html exposing (Html, div, text)

main : Html msg
main =
  div [] [ text "Picshare" ]
