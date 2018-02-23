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
import Html.Events exposing (onClick)

-- Type aliases allow us to associate a type name with another type. One common
-- example would be `type alias Id = Int` to call Integers Ids. Here we are
-- creating a type alias for our applications record model. This saves us from
-- having to repeat { url : String, caption : String, liked : Bool } everywhere.
type alias Model =
  { url : String
  , caption : String
  , liked : Bool
  }

-- Return a base URL for our photos
baseUrl : String
baseUrl =
  "https://unsplash.it/"

-- Our initialModel is a Record (very much like JS objects).
-- initialModel is a common pattern in Elm apps to define the initial state.
initialModel : Model
initialModel =
  { url = baseUrl ++ "800/600"
  , caption = "Stealing from Unsplash"
  , liked = False
  }


-- Create a single photo html representation from a model
viewDetailedPhoto : Model -> Html Msg
viewDetailedPhoto model =
  let
    buttonClass =
      if model.liked then
        "fa-heart"
      else
        "fa-heart-o"

    msg =
      if model.liked then
        Unlike
      else
        Like
  in
  div [ class "detailed-photo" ]
      [ img [src model.url] []
      , div [ class "photo-info" ]
        [ div [ class "like-button" ]
          [ i
            [ class "fa fa-2x"
            , class buttonClass
            , onClick msg
            ]
            []
          ]
        , h2 [ class "caption" ] [ text model.caption ]
        ]
      ]

-- Views in Elm are functions that take a model and return a virtual DOM tree
-- `div` and other HTML functions take two lists: attributes and child nodes.
-- `main` can only have one root element, so we need to wrap it to a div here.
view : Model -> Html Msg
view model =
  div []
      [ div [class "header"]
          [ h1 [] [ text "Picshare" ] ]
        , div [class "content-flow"]
          [ viewDetailedPhoto model
          ]
      ]

-- Create our own union type that we can use for our Msg
type Msg
  = Like
  | Unlike

-- All changes to the model in Elm has to happen in an `update` function.
-- The update function takes two arguments, a `message` and a `model`.
-- The message comes from Elm's runtime in response to events such as clicks.
-- The message describes the type of state change. Because data types in Elm
-- are immutable, the update function must return a new model.
-- Our update function takes in a Msg (as defined above) and a record model,
-- and returns a model based on what the pattern matches to.
update : Msg -> Model -> Model
update msg model =
  case msg of
    Like ->
      { model | liked = True } -- each branch is an expression in Elm, so no need for `break`

    Unlike ->
      { model | liked = False } -- no need for default branch in Elm, as we know possible matches

-- A `program` in Elm ties together the model, view function and update function.
-- This is how Elm is able to subscribe to DOM events, dispatch messages to our
-- update function, update our state based on the result of our update function,
-- and display the changes in the browser.
-- Here we pass model, view and update to the beginnerProgram that takes care of
-- the rest for us.
-- Here the `Never` means that the type variable `flags` for the Program type never takes any values.
-- The other two things we pass is the model and the msg.
main : Program Never Model Msg
main =
  Html.beginnerProgram
    { model = initialModel
    , view = view
    , update = update
    }
