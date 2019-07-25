module Main exposing (..)

import Array as Array
import Html exposing (..)
import Html.Events exposing (onClick)
import Browser exposing (sandbox)
import Bitwise exposing (shiftRightBy, shiftLeftBy, and)

type alias Model =
    { state : Array.Array Int
    , index : Int
    , randomNum : Float
    }

init : Model
init =
    { state = Array.fromList <| List.indexedMap (\idx _ -> idx) <| List.repeat 623 0
    , index = 0
    , randomNum = 0
    }

int32 : Int -> Int
int32 input =
    -- hex 0xFFFFFFFF
    Bitwise.and 0xFFFFFFFF (input)

generateNumbers : Model -> Model
generateNumbers model =
    let
        idxMapFunc : Int -> Int -> Int
        idxMapFunc idx currentElem =
            let
                nextElem = Array.get (modBy 624 <| idx + 1) model.state |> Maybe.withDefault 0
                y  = (Bitwise.and currentElem 0x80000000) + (Bitwise.and nextElem 0x7fffffff)

                newElem =
                    let
                        x = (Array.get (modBy 624 <| idx + 397) model.state|> Maybe.withDefault 0)
                    in
                        Bitwise.xor x (Bitwise.shiftRightBy 1 y)
            in
                if (modBy 2 y) /= 0 then
                    Bitwise.xor newElem 2567483615
                else
                    newElem
    in
        { model | state = Array.indexedMap idxMapFunc model.state }


extractNumbers : Model -> Model
extractNumbers model =
    let
        newModel = if model.index == 0 then generateNumbers model else model

        y = (Array.get (newModel.index) newModel.state |> (Maybe.withDefault 0))
        a = Bitwise.xor y (shiftRightBy 11 y)
        b = Bitwise.xor a (Bitwise.and (shiftLeftBy 7 a) 2636928640)
        c = Bitwise.xor b (Bitwise.and (shiftLeftBy 15 b) 4022730752)
        d = Bitwise.xor c (shiftRightBy 18 y)

        newidx = modBy 624 <| newModel.index + 1
    in
        { newModel | index = newidx, randomNum = toFloat <| int32 d }

generateRandomNumber : Float -> Float -> Float -> Float
generateRandomNumber lowerBound upperBound seed =
    let
        boundDiff = 
            upperBound - lowerBound

        model =
            { state = Array.fromList <| List.indexedMap (\idx _ -> idx) <| List.repeat 624 0
            , index = 0
            , randomNum = 0
            }
            
        newState = 
            Array.set 0 (round seed) model.state

        idxMapFunc : Int -> Int -> Int
        idxMapFunc idx num =
            if idx /= 0 then
                let
                    foldFunc : (Int, Int) -> (Int, Int) -> (Int, Int)
                    foldFunc (index1, fstElem) (index2, lstElem) =
                    -- [(0, 1), (1, 1812433254), (2, 1812433255), (3, -670100787)]
                        ( index2, (1812433253 * (Bitwise.xor fstElem (Bitwise.shiftRightBy 30 fstElem) ) + index2 ))    

                    prevElem = 
                        Array.foldl foldFunc (0, round seed) (Array.indexedMap Tuple.pair <| Array.slice 1 idx newState)
                            |> Tuple.second
                in
                    (1812433253 * (Bitwise.xor prevElem (Bitwise.shiftRightBy 30 prevElem) ) + idx )
                        |> int32
            else
                num

        newModel = 
            extractNumbers { model | state = (Array.indexedMap idxMapFunc newState), index = 0 }
    in
        lowerBound + toFloat (modBy (round boundDiff) (round newModel.randomNum))

type Msg = 
    GenRand Float   

update : Msg -> Model -> Model
update msg model =
    case msg of
        GenRand seed ->
            { model | randomNum = generateRandomNumber (-2^31) (2^31 - 1) seed }


view : Model -> Html Msg
view model =
    div [] 
        [ div [] [ text <| String.fromFloat model.randomNum ]
        , button [ onClick (GenRand 2) ] [ text "GetRandomNum" ]
        ]

main : Program () Model Msg
main = 
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }
