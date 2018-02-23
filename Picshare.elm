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
import Html.Attributes exposing (class, disabled, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode exposing (Decoder, bool, int, list, string)
import Json.Decode.Pipeline exposing (decode, hardcoded, required)
import Http

-- Type aliases allow us to associate a type name with another type. One common
-- example would be `type alias Id = Int` to call Integers Ids. Here we are
-- creating a type alias for our applications record model. This saves us from
-- having to repeat { url : String, caption : String, ...etc } everywhere.
type alias Id =
  Int

type alias Photo =
  { id : Id
  , url : String
  , caption : String
  , liked : Bool
  , comments : List String
  , newComment : String
  }

type alias Feed =
  List Photo

-- Maybe represents a value that may or may not exist. If it does, then it has Just
-- that value. If it does not exist, we have Nothing.
type alias Model =
  { feed : Maybe Feed
  , error : Maybe Http.Error
  }

{- Our JSON decoder for our photos.

Elm's JSON Decoders solve the problem with external JSON being untyped by making
sure that the payload matches a specific shape. This way our pure Elm application
can safely interact with outside input such as a JSON response from an API without
throwing away the safety guarantees.

We’re not calling decode on the Photo type but the Photo constructor function,
and then pipe the decoder through helper functions to extract properties and apply
them to the underlying function.
-}
photoDecoder : Decoder Photo
photoDecoder =
  decode Photo
    |> required "id" int
    |> required "url" string
    |> required "caption" string
    |> required "liked" bool
    |> required "comments" (list string)
    |> hardcoded "" -- use a static value for newComment, as that's not coming with our JSON but is part of Photo

-- Return a base URL for our photos
baseUrl : String
baseUrl =
  "https://programming-elm.com/"

-- Our initialModel is a Record (very much like JS objects).
-- initialModel is a common pattern in Elm apps to define the initial state.
-- Here we set initialModel photo to be Nothing, as we fetch it via an API later.
initialModel : Model
initialModel =
  { feed = Nothing
  , error = Nothing
  }

-- The init constant is a `tuple`. The Elm architecture uses the `init` pair to
-- bootstrap the initial state and run any initial commands for our application.
-- In this case, we provide the initialModel and fetchFeed to fetch a photo when
-- the application starts.
init : ( Model, Cmd Msg )
init =
  ( initialModel, fetchFeed )

-- Basic GET request for our JSON data. We pass in two arguments, a string url
-- and a decoder. Http.get returns an Http.Request that resolves to whatever type
-- the decoder creates. This is then passed into Http.send.
-- Cmds or Commands are special values that instruct the Elm architecture to perform
-- actions such as sending HTTP requests.
fetchFeed : Cmd Msg
fetchFeed =
  Http.get (baseUrl ++ "feed") (list photoDecoder)
    |> Http.send LoadFeed -- NOTE: Does not actually _send_ the request, instead it returns a Cmd to do so

-- Our lovebutton component
viewLoveButton : Photo -> Html Msg
viewLoveButton photo =
  let
    buttonClass =
      if photo.liked then
        "fa-heart"
      else
        "fa-heart-o"
  in
  div [ class "like-button" ]
    [ i
      [ class "fa fa-2x"
      , class buttonClass
      , onClick (ToggleLike photo.id)
      ]
      []
    ]

-- Single comment
viewComment : String -> Html Msg
viewComment comment =
  li []
    [ strong [] [ text "Comment:" ]
    , text (" " ++ comment)
    ]

-- List of comments
viewCommentList : List String -> Html Msg
viewCommentList comments =
  case comments of
    [] ->
      text ""
    _ ->
      div [ class "comments" ]
        [ ul []
          (List.map viewComment comments)
        ]

-- Showing and adding new comments
viewComments : Photo -> Html Msg
viewComments photo =
  div []
    [ viewCommentList photo.comments
    , form [ class "new-comment" , onSubmit (SaveComment photo.id) ] -- Message on submit
      [ input
        [ type_ "text" -- The underscore here is to avoid the `type` keyword
        , placeholder "Add a comment.."
        , value photo.newComment -- Lets the value reflect what is in the models newComment field
        , onInput (UpdateComment photo.id)
        ]
        []
      , button [disabled (String.isEmpty photo.newComment)] [ text "Save" ] -- Disable button IF newComment field of our model is empty
      ]
    ]

-- Create a single photo html representation from a model
viewDetailedPhoto : Photo -> Html Msg
viewDetailedPhoto model =
  div [ class "detailed-photo" ]
      [ img [src model.url] []
      , div [ class "photo-info" ]
        [ viewLoveButton model
        , h2 [ class "caption" ] [ text model.caption ]
        , viewComments model
        ]
      ]

-- Helper function to see if we actually have a photo to display (as the type
-- passed in is Maybe Photo instead of a Photo).
viewFeed : Maybe Feed -> Html Msg
viewFeed maybeFeed =
  case maybeFeed of
    Just feed ->
      div [] (List.map viewDetailedPhoto feed)

    Nothing ->
      div [ class "loading-feed" ]
          [ text "Loading feed..." ]

errorMessage : Http.Error -> String
errorMessage error =
  case error of
    Http.BadPayload _ _ ->
      """Sorry, we couldn't process your feed at this time.
         We're working on it!"""
    _ ->
      """Sorry, we couldn't load your feed. Please try again later"""

-- Helper to display errors if they are present
viewContent : Model -> Html Msg
viewContent model =
  case model.error of
    Just error ->
      div [ class "feed-error" ]
          [ text (errorMessage error) ]

    Nothing ->
      viewFeed model.feed

-- Views in Elm are functions that take a model and return a virtual DOM tree
-- `div` and other HTML functions take two lists: attributes and child nodes.
-- `main` can only have one root element, so we need to wrap it to a div here.
view : Model -> Html Msg
view model =
  div []
      [ div [class "header"]
          [ h1 [] [ text "Picshare" ] ]
        , div [class "content-flow"]
          [ viewContent model
          ]
      ]

{-
Create our own union type that we can use for our Msg.

The LoadFeed type constructor takes one argument, a Result type. The inner Result
type then uses the Http.Error type for the `error` variable and Photo for the `value`
type variable.
-}
type Msg
  = ToggleLike Id
  | UpdateComment Id String
  | SaveComment Id
  | LoadFeed (Result Http.Error Feed)

-- Helper function used in our `update` function to save a new comment in our model
saveNewComment : Photo -> Photo
saveNewComment model =
  case model.newComment of
    "" ->
      model

    _ ->
      let
        comment =
          String.trim model.newComment
      in
      {model | comments = model.comments ++ [ comment ], newComment = ""}

-- Helper functions for a cleaner update function
toggleLike : Photo -> Photo
toggleLike photo =
  { photo | liked = not photo.liked }

updateComment : String -> Photo -> Photo
updateComment comment photo =
  { photo | newComment = comment }

-- Helper to update photo by given ID.
-- Maps over the feed with List.map, passing in an anonymous mapping function to
-- inspect each photos id. If that photo id matches the id argument, we apply
-- updatePhoto to the matching photo and return the transformed photo. Otherwise,
-- we return the photo with no change.
updatePhotoById : (Photo -> Photo) -> Id -> Feed -> Feed
updatePhotoById updatePhoto id feed =
  List.map
  (\photo ->
    if photo.id == id then
      updatePhoto photo
    else
      photo
    )
    feed

{- Maybe.map transforms whatever could be inside a Maybe type. It takes a
transformation function as the first argument and then Maybe value as the second
argument. If the Maybe value is a Just, then Maybe.map will create a new Just
with the transformation function applied to the inner Just value. If the Maybe
is Nothing, then Maybe.map will return back Nothing.
-}
updateFeed : (Photo -> Photo) -> Id -> Maybe Feed -> Maybe Feed
updateFeed updatePhoto id maybeFeed =
  Maybe.map (updatePhotoById updatePhoto id) maybeFeed

-- All changes to the model in Elm has to happen in an `update` function.
-- When we use Html.program, the update function needs to return a tuple just like
-- the `init` tuple. This allows the update function to hand off more commands to
-- the Elm architecture.

-- In other words, we now return tuples where the first item is the model update
-- (which the Elm architecture uses to update our application state), and the
-- second item is a call to the function Cmd.none (which produces a command that does nothing).
-- This is done to satisfy the type constraint of always returning a tuple pair
-- containing Model and Cmd Msg.

-- Instead of using model.photo directly, we use updateFeed to pass in one of our
-- helper functions to update the inner photo if it exists.
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToggleLike id ->
      ( { model
          | feed = updateFeed toggleLike id model.feed
        } -- Toggle to the opposite on update
      , Cmd.none
      )

    UpdateComment id comment ->
      ( { model
          | feed = updateFeed (updateComment comment) id model.feed
        }
      , Cmd.none
      )

    SaveComment id ->
      ( { model
          | feed = updateFeed saveNewComment id model.feed
        }, Cmd.none
      )

    LoadFeed (Ok feed) ->
      ( { model | feed = Just feed }
        , Cmd.none
        )

    LoadFeed (Err error) ->
      ( { model | error = Just error }, Cmd.none )

{- This subscriptions doesn't really do anything now, but we need this no-op
implementation for now to create the correct type of record that Html.program
requires.

Briefly, the subscriptions function takes the model as an argument and needs to
return a Sub msg type. We will eventually return Sub Msg, so we use that in our
type signature. For now, we use Sub.none to return a no-op subscription (much
like how Cmd.none returns a command that does nothing).
-}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

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
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
