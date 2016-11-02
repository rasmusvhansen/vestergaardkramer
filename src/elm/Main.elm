port module Main exposing (..)

import Routing
import Commands exposing (..)
import Messages exposing (..)
import Model exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as Encode
import Navigation
import String


main =
    Navigation.program Routing.urlParser
        { init = init
        , view = view
        , update = update
        , urlUpdate = Routing.urlUpdate
        , subscriptions = (\_ -> listItems Messages.GotWishes)
        }



-- MODEL


init : Result String Route -> ( Model, Cmd Msg )
init result =
    Routing.urlUpdate result emptyModel



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
                ( { model | wishes = List.map updateWish model.wishes }, fbTakeWish ( "rasmus", { wish | taken = isTaken } ) )

        WishTitle title ->
            ( updateWish model (\wish -> { wish | title = title }), Cmd.none )

        WishDescription description ->
            ( updateWish model (\wish -> { wish | description = description }), Cmd.none )

        SaveWish ->
            ( { model | wish = emptyWish }, fbPush model.wish )

        Login ->
            ( model, Commands.login (Debug.log "logging in" "") )


emptyWish : Wish
emptyWish =
    Wish Nothing "" "" False


updateWish : Model -> (Wish -> Wish) -> Model
updateWish model wishMaker =
    let
        wish =
            wishMaker model.wish
    in
        { model | wish = wish }



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
        [ nav [ class "navbar" ]
            [ div [ class "container" ]
                [ viewMenu
                ]
            ]
        , div
            [ class "row" ]
            [ div [ class "one-half column" ]
                [ subView model ]
            ]
        ]


subView : Model -> Html Msg
subView model =
    case model.route.route of
        Just "wishes" ->
            viewWishes model

        Just "wishadmin" ->
            viewWishAdmin model

        _ ->
            viewWishes model


viewWishes : Model -> Html Msg
viewWishes model =
    div []
        [ h1 [] [ text "Ønsker" ]
        , div [] (List.map viewWish model.wishes)
        ]


viewWishItem : String -> Html Msg
viewWishItem name =
    li [] [ a [ href ("#/wishes/" ++ String.toLower name) ] [ text name ] ]


viewMenu : Html Msg
viewMenu =
    ul [ class "menu" ]
        [ button [ onClick Login ] [ text "Login" ]
        , viewWishItem "Rasmus"
        , viewWishItem "Camilla"
        , viewWishItem "Jonas"
        , viewWishItem "Mads"
        , viewWishItem "Carl"
        ]


viewWishAdmin : Model -> Html Msg
viewWishAdmin model =
    div []
        [ Html.form [ class "one-half column", onSubmit SaveWish ]
            [ h3 [] [ text "Rediger" ]
            , div [ class "row" ]
                [ label [ for "titel" ] [ text "Titel" ]
                , input [ placeholder "Titel", id "titel", onInput WishTitle, value model.wish.title ] []
                , label [ for "description" ] [ text "Beskrivelse" ]
                , textarea [ placeholder "Beskrivelse", id "description", onInput WishDescription, value model.wish.description ] []
                , br [] []
                , input [ type' "submit", class "button-primary", value "Opret" ] []
                ]
            ]
        ]
