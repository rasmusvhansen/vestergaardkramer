module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.App as App
import Html.Attributes exposing (..)


main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Wish =
    { person : String
    , title : String
    , description : String
    , taken : Bool
    }


type alias Model =
    { wishes : List Wish
    }


init : ( Model, Cmd Msg )
init =
    ( Model
        [ Wish "Rasmus" "Book" "Some book" False
        , Wish "Rasmus" "En and" "En fin and" True
        ]
    , Cmd.none
    )



-- UPDATE


type Msg
    = ToggleWish Wish Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleWish wish isTaken ->
            let
                updateWish w =
                    if w == wish then
                        { w | taken = isTaken }
                    else
                        w
            in
                { model | wishes = List.map updateWish model.wishes }
                    ! []



-- case msg of
--     Tick newTime ->
--         ( newTime, Cmd.none )
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


viewWish : Wish -> Html Msg
viewWish wish =
    div [ class "wish" ]
        [ label []
            [ h5 []
                [ input
                    [ type' "checkbox"
                    , checked wish.taken
                    , onClick (ToggleWish wish (not wish.taken))
                    ]
                    []
                , text (" " ++ wish.title)
                ]
            ]
        , p [] [ text wish.description ]
        ]


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "one-half column" ]
                [ h1 [] [ text "Ønsker" ]
                , div [] (List.map viewWish model.wishes)
                ]
            ]
        ]
