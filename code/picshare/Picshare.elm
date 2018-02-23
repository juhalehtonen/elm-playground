{-
Every Elm file is a module. Modules let you organize code into logical units.
Every module contains one or more constants and functions that it can expose
to other modules. The name of `main` constant is important but not the modules
name.
-}
module Picshare exposing (main)
-- We expose the Html TYPE constructor to represent HTML, in addition to div and
-- text functions. Html essentially represents the virtual DOM. We could do:
-- import Html exposing (Html, div, h1, text)
-- ..but because we need a shitton of HTML elements, we will instead do:
import Html exposing (..)
-- The Html.Attributes module contains functions for adding attributes to virtual
-- DOM nodes.
import Html.Attributes exposing (class, src)

baseUrl : String
baseUrl =
  "https://programming-elm.com/"

-- Our initialModel is a Record (very much like JS objects).
-- initialModel is a common pattern in Elm apps to define the initial state.
initialModel : { url : String, caption : String }
initialModel =
  { url = baseUrl ++ "1.jpg"
  , caption = "Surfing"
  }

-- Views in Elm are functions that take a model and return a virtual DOM tree

viewDetailedPhoto : { url : String, caption : String } -> Html msg
viewDetailedPhoto model =
  div [ class "detailed-photo" ]
      [ img [src model.url] []
      , div [ class "photo-info" ]
        [ h2 [ class "caption" ] [ text model.caption ] ]
      ]

-- `div` and other HTML functions take two lists: attributes and child nodes.
-- `main` can only have one root element, so we need to wrap it to a div here.
view : { url : String, caption : String } -> Html msg
view model =
  div []
      [ div [class "header"]
          [ h1 [] [ text "Picshare" ] ]
        , div [class "content-flow"]
          [ viewDetailedPhoto model
          ]
      ]

-- Main ties the model and view together by passing in initialModel to the view function.
main : Html msg
main =
  view initialModel
