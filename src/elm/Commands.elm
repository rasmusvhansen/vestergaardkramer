port module Commands exposing (..)

import Model exposing (..)
import Messages exposing (..)
import Http exposing (Body)
import Json.Decode as Decode exposing ((:=))
import Json.Encode as Encode
import Task
import Dict


port fbPush : Wish -> Cmd msg


port fbTakeWish : Wish -> Cmd msg


port fbRemove : WishId -> Cmd msg


port getWishes : String -> Cmd msg


port login : String -> Cmd msg


port listItems : (Encode.Value -> msg) -> Sub msg


receive : Encode.Value -> Cmd Msg
receive json =
    let
        decodedItemsResult =
            Decode.decodeValue (Decode.dict itemsDecoder) json

        mappedItems =
            case decodedItemsResult of
                Ok decodedItems ->
                    Dict.toList decodedItems
                        |> List.map includeUniqueId

                Err err ->
                    Debug.log err []
    in
        Task.perform identity WishUpdate (Task.succeed mappedItems)


includeUniqueId : ( String, Wish ) -> Wish
includeUniqueId ( uniqueId, item ) =
    { item | id = Just uniqueId }


itemsDecoder : Decode.Decoder Wish
itemsDecoder =
    Decode.object5 Wish
        (Decode.maybe ("id" := Decode.string))
        ("title" := Decode.string)
        ("description" := Decode.string)
        ("taken" := Decode.bool)
        ("person" := Decode.string)



-- itemEncoded : Wish -> Encode.Value
-- itemEncoded item =
--     let
--         id =
--             case item.id of
--                 Just itemId ->
--                     itemId
--                 Nothing ->
--                     ""
--     in
--         [ ( "id", Encode.string id )
--         , ( "title", Encode.string item.title )
--         , ( "description", Encode.string item.description )
--         , ( "taken", Encode.bool item.taken )
--         ]
--             |> Encode.object
