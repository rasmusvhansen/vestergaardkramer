module Messages exposing (..)

import Model exposing (..)
import Json.Encode as Encode


type Msg
    = ToggleWish Wish Bool
    | WishUpdate (List Wish)
    | GotWishes Encode.Value
    | WishTitle String
    | WishDescription String
    | SaveWish
