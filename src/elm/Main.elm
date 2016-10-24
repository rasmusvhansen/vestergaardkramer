port module Main exposing (..)

import Commands exposing (..)
import Messages exposing (..)
import Model exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Json.Encode as Encode
import Navigation
import String


main =
    Navigation.program urlParser
        { init = init
        , view = view
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = (\_ -> listItems Messages.GotWishes)
        }


type alias Route =
    { route : Maybe String
    , params : Maybe (List String)
    }


initModel : Model
initModel =
    Model [] { title = "", description = "", taken = False, id = Nothing } Nothing


urlUpdate : Result String Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    case result of
        Ok route ->
            case ( route.route, route.params ) of
                ( Just "wishes", Just (person :: rest) ) ->
                    ( initModel, getWishes (Debug.log "person" person) )

                _ ->
                    ( initModel, Cmd.none )

        Err _ ->
            ( model, Cmd.none )


urlParser : Navigation.Parser (Result String Route)
urlParser =
    Navigation.makeParser (fromUrl << .hash)


fromUrl : String -> Result String Route
fromUrl url =
    let
        parts =
            String.split "/" (String.dropLeft 2 (Debug.log "url" url))
    in
        Ok (Route (List.head parts) (List.tail parts))


port getWishes : String -> Cmd msg


port listItems : (Encode.Value -> msg) -> Sub msg



-- MODEL


type alias Model =
    { wishes : List Wish
    , wish : Wish
    , error : Maybe String
    }


init : Result String Route -> ( Model, Cmd Msg )
init result =
    ( initModel, getWishes "rasmus" )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotWishes json ->
            ( model, (receive json) )

        WishUpdate newWishes ->
            ( { model | wishes = newWishes }, Cmd.none )

        ToggleWish wish isTaken ->
            let
                updateWish w =
                    if w == wish then
                        { w | taken = isTaken }
                    else
                        w
            in
                ( { model | wishes = List.map updateWish model.wishes }, persist { wish | taken = isTaken } )

        WishTitle title ->
            ( { model | wish = { title = title, description = model.wish.description, taken = model.wish.taken, id = model.wish.id } }, Cmd.none )

        WishDescription description ->
            ( { model | wish = { title = model.wish.title, description = description, taken = model.wish.taken, id = model.wish.id } }, Cmd.none )

        SaveWish ->
            ( { model | wish = { title = "", description = "", taken = False, id = Nothing } }, persist model.wish )



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
            , Html.form [ class "one-half column", onSubmit SaveWish ]
                [ h3 [] [ text "Rediger" ]
                , div [ class "row" ]
                    [ label [ for "titel" ] [ text "Titel" ]
                    , input [ placeholder "Titel", id "titel", onInput WishTitle, value model.wish.title ] []
                    , label [ for "description" ] [ text "Beskrivelse" ]
                    , textarea [ placeholder "Beskrivelse", id "description", onInput WishDescription, value model.wish.description ] []
                    , br [] []
                    , input [ type' "submit", class "button-primary" ] [ text "Opret" ]
                    ]
                ]
            ]
        ]
