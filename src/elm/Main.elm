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
import Char
import Regex exposing (..)


main =
    Navigation.program Routing.urlParser
        { init = init
        , view = view
        , update = update
        , urlUpdate = Routing.urlUpdate
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ listItems Messages.GotWishes
        , user Messages.UserLoggedIn
        ]



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

        DeleteWish wish ->
            ( model, fbRemove wish )

        Login ->
            ( model, Commands.login (Debug.log "logging in" "") )

        UserLoggedIn user ->
            ( { model | user = Just user }, Cmd.none )


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


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ nav [ class "navbar" ]
            [ div [ class "container" ]
                [ viewMenu model.user
                ]
            ]
        , div
            [ class "row" ]
            [ div [ class "one-half column" ]
                [ subView model ]
            ]
        ]


viewDeleteWish : Maybe String -> Wish -> Html Msg
viewDeleteWish user wish =
    case user of
        Nothing ->
            text ""

        Just u ->
            button [ class "fa fa-trash wish__delete", onClick (DeleteWish wish) ] []


viewWish : Maybe String -> Wish -> Html Msg
viewWish user wish =
    li [ class "wish" ]
        [ label []
            [ viewDeleteWish user wish
            , input
                [ type' "checkbox"
                , checked wish.taken
                , onClick (ToggleWish wish (not wish.taken))
                ]
                []
            , text (" " ++ wish.title)
            ]
        , p [] [ linkifyDescription wish.description ]
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


addWish : Maybe String -> Maybe String -> Html Msg
addWish person user =
    case ( person, user ) of
        ( Just p, Just _ ) ->
            a [ href ("#/wishadmin/" ++ String.toLower p) ] [ text "Opret nyt ønske" ]

        _ ->
            text ""


viewWishes : Model -> Html Msg
viewWishes model =
    div []
        [ h1 []
            [ text "Ønsker for "
            , Maybe.withDefault (text "ukendt") (Maybe.map (\w -> text (capitalize w.person)) model.wish)
            ]
        , addWish (Maybe.map (\w -> w.person) model.wish) model.user
        , ul [ class "wishes" ] (List.map (viewWish model.user) model.wishes)
        ]


viewWishItem : String -> Html Msg
viewWishItem name =
    li [] [ a [ href ("#/wishes/" ++ String.toLower name) ] [ text name ] ]


viewMenu : Maybe String -> Html Msg
viewMenu user =
    ul [ class "menu" ]
        [ viewUser user
        , viewWishItem "Rasmus"
        , viewWishItem "Camilla"
        , viewWishItem "Jonas"
        , viewWishItem "Mads"
        , viewWishItem "Carl"
        ]


viewUser : Maybe String -> Html Msg
viewUser user =
    case user of
        Just u ->
            text u

        _ ->
            button [ onClick Login ] [ text "Login" ]


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



-- functions


capitalize : String -> String
capitalize string =
    case String.uncons string of
        Nothing ->
            ""

        Just ( head, tail ) ->
            String.cons (Char.toUpper head) tail
