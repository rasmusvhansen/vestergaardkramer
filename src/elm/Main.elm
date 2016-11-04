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
import Regex exposing (..)


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
                ( { model | wishes = List.map updateWish model.wishes }, fbTakeWish { wish | taken = isTaken } )

        WishTitle title ->
            ( updateWish model (\wish -> { wish | title = title }), Cmd.none )

        WishDescription description ->
            ( updateWish model (\wish -> { wish | description = description }), Cmd.none )

        SaveWish wish ->
            ( { model | wish = Just (initWish wish.person) }, fbPush wish )

        Login ->
            ( model, Commands.login (Debug.log "logging in" "") )


updateWish : Model -> (Wish -> Wish) -> Model
updateWish model wishMaker =
    let
        wish =
            Maybe.map wishMaker model.wish
    in
        { model | wish = wish }



-- VIEW


linkifyDescription : String -> Html Msg
linkifyDescription description =
    let
        parts =
            String.split "|||" (replace All (regex "https?://\\S*") (\{ match } -> "|||" ++ match ++ "|||") description)
    in
        span []
            (List.map
                (\part ->
                    if (String.startsWith "http" part) then
                        a [ href part, target "_blank" ] [ text part ]
                    else
                        text part
                )
                parts
            )


viewWish : Wish -> Html Msg
viewWish wish =
    li [ class "wish" ]
        [ label []
            [ input
                [ type' "checkbox"
                , checked wish.taken
                , onClick (ToggleWish wish (not wish.taken))
                ]
                []
            , text (" " ++ wish.title)
            ]
        , p [] [ linkifyDescription wish.description ]
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
            case model.wish of
                Just wish ->
                    viewWishAdmin wish

                _ ->
                    text "ERROR NO WISH DEFINED"

        _ ->
            viewWishes model


viewWishes : Model -> Html Msg
viewWishes model =
    div []
        [ h1 [] [ text "Ønsker" ]
        , ul [ class "wishes" ] (List.map viewWish model.wishes)
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


viewWishAdmin : Wish -> Html Msg
viewWishAdmin wish =
    div []
        [ Html.form [ class "one-half column", onSubmit (SaveWish wish) ]
            [ h3 [] [ text "Rediger" ]
            , div [ class "row" ]
                [ label [ for "titel" ] [ text "Titel" ]
                , input [ placeholder "Titel", id "titel", onInput WishTitle, value wish.title ] []
                , label [ for "description" ] [ text "Beskrivelse" ]
                , textarea [ placeholder "Beskrivelse", id "description", onInput WishDescription, value wish.description ] []
                , br [] []
                , input [ type' "submit", class "button-primary", value "Opret" ] []
                ]
            ]
        ]
